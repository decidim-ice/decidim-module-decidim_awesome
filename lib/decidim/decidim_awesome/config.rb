# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # The current awesome config for the organization.
    class Config
      def initialize(organization)
        @organization = organization
        @vars = AwesomeConfig.for_organization(organization).includes(:constraints)
        @context = {
          participatory_space_manifest: nil,
          participatory_space_slug: nil,
          component_id: nil,
          component_manifest: nil
        }
        @sub_configs = {}
      end

      attr_reader :context, :organization, :vars
      attr_writer :defaults

      def defaults
        @defaults || Decidim::DecidimAwesome.config
      end

      def context=(context)
        @config = nil
        @context = context
      end

      # convert context to manifest, slug and id
      def context_from_request(request)
        @config = nil
        @context = Decidim::DecidimAwesome::ContextAnalyzers::RequestAnalyzer.context_for request
      end

      # convert component to manifest, slug and id
      def context_from_component(component)
        @config = nil
        @context = Decidim::DecidimAwesome::ContextAnalyzers::ComponentAnalyzer.context_for component
      end

      # convert participatory space to manifest, slug and id
      def context_from_participatory_space(space)
        @config = nil
        @context = Decidim::DecidimAwesome::ContextAnalyzers::ParticipatorySpaceAnalyzer.context_for space
      end

      # config processed in context
      def config
        @config ||= calculate_config
      end

      # config processed for the organization config, without context
      def organization_config
        @organization_config ||= unfiltered_config.map do |key, value|
          value = defaults[key] unless enabled_for_organization? key
          [key, value]
        end.to_h
      end

      # config normalized according default values, without context, without organization config
      def unfiltered_config
        valid = @vars.map { |v| [v.var.to_sym, v.value] }.to_h

        map_defaults do |key, val|
          valid.has_key?(key) ? valid[key] : val
        end
      end

      def setting_for(var)
        @vars.find_or_initialize_by(
          organization: @organization,
          var: var
        )
      end

      # Checks if some config option es enabled in a certain context
      def enabled_for?(setting)
        config[setting]
      end

      # checks if some constraint blocks the validity fot the current context
      def valid_in_context?(constraints)
        # if no constraints defined, applies to everything
        return true if constraints.blank?

        # if containts the "none" constraints, deactivate everything else
        return false if constraints.detect { |c| c.settings["participatory_space_manifest"] == "none" }

        # check if current context matches some constraint
        constraints.detect do |constraint|
          settings = constraint.settings.symbolize_keys
          match_method = settings.delete(:match)
          if match_method == "exclusive"
            # all keys must match
            settings == context
          else
            # constraints keys can match the context partially (ie: if slug is not specified, any space matches in the same manifest)
            # if some setting is different, rejects
            invalid = constraint.settings.detect { |key, val| context[key.to_sym].to_s != val.to_s }
            invalid.blank?
          end
        end
      end

      # adds some custom constraints for the instance that can be generated dynamically
      def inject_sub_config_constraints(singular_key, subkey, constraints)
        sub_configs_for(singular_key)[subkey.to_sym]&.add_constraints constraints
      end

      # Merges all subconfigs values for custom_styles or any other scoped confs
      # by default filtered according to the current scope, a block can be passed for custom filtering
      # ie, collect everything:
      #    collect_sub_configs_values("scoped_style") { true }
      def collect_sub_configs_values(singular_key)
        plural_key = singular_key.pluralize.to_sym
        return [] unless config[plural_key].respond_to?(:filter)

        fields = config[plural_key]&.filter do |key, _value|
          subconfig = sub_configs_for(singular_key)[key]
          # allow custom filtering if block given
          if block_given?
            yield subconfig
          else
            valid_in_context?(subconfig&.all_constraints)
          end
        end
        fields.values
      end

      def sub_configs_for(singular_key)
        return @sub_configs[singular_key] if @sub_configs[singular_key]

        plural_key = singular_key.pluralize.to_sym
        return {} unless config[plural_key]

        @sub_configs[singular_key] = config[plural_key].map do |key, _value|
          [key, AwesomeConfig.find_by(var: "#{singular_key}_#{key}", organization: @organization)]
        end.to_h
      end

      private

      def map_defaults
        defaults.map do |key, val|
          value = false
          unless val == :disabled
            value = yield(key, val)
            value = val.merge(value.transform_keys(&:to_sym)) if val.is_a?(Hash) && value.is_a?(Hash)
          end
          [key, value]
        end.to_h
      end

      def calculate_config
        # filter vars compliant with current context
        valid = @vars.filter { |item| enabled_for_organization?(item.var) && valid_in_context?(item.all_constraints) }
                     .map { |v| [v.var.to_sym, v.value] }.to_h

        map_defaults do |key, val|
          valid.has_key?(key) ? valid[key] : val
        end
      end

      # extra checks that may be relevant for the key
      def enabled_for_organization?(key)
        case key.to_sym
        when :allow_images_in_proposals
          return false if @organization.rich_text_editor_in_public_views
        end
        true
      end
    end
  end
end
