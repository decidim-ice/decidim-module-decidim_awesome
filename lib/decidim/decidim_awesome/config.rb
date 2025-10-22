# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # The current awesome config for the organization.
    class Config
      def initialize(organization)
        @organization = organization
        @vars = AwesomeConfig.for_organization(organization).includes(:constraints)
        @saved_vars = @vars.map(&:var).map(&:to_sym)
        @context = {
          participatory_space_manifest: nil,
          participatory_space_slug: nil,
          component_id: nil,
          component_manifest: nil,
          application_context: "anonymous"
        }
        @sub_configs = {}
      end

      attr_reader :context, :organization, :vars, :application_context, :saved_vars
      attr_writer :defaults

      def defaults
        @defaults || Decidim::DecidimAwesome.config
      end

      def context=(context)
        @config = nil
        @context = context
      end

      # convert context to manifest, slug and id
      def context_from_request!(request)
        @config = nil
        @context = Decidim::DecidimAwesome::ContextAnalyzers::RequestAnalyzer.context_for request
      end

      # convert component to manifest, slug and id
      def context_from_component!(component)
        @config = nil
        @context = Decidim::DecidimAwesome::ContextAnalyzers::ComponentAnalyzer.context_for component
      end

      # convert participatory space to manifest, slug and id
      def context_from_participatory_space!(space)
        @config = nil
        @context = Decidim::DecidimAwesome::ContextAnalyzers::ParticipatorySpaceAnalyzer.context_for space
      end

      def application_context!(ctx = {})
        @application_context = ctx
        @context[:application_context] = case ctx[:current_user]
                                         when Decidim::User
                                           "user_logged_in"
                                         else
                                           "anonymous"
                                         end
      end

      # config processed in context
      def config
        @config ||= calculate_config
      end

      # config processed for the organization config, without context
      def organization_config
        @organization_config ||= unfiltered_config.to_h do |key, value|
          value = defaults[key] unless enabled_for_organization? key
          [key, value]
        end
      end

      # config normalized according default values, without context, without organization config
      def unfiltered_config
        valid = @vars.to_h { |v| [v.var.to_sym, v.value] }

        map_defaults do |key, val|
          valid[key].nil? ? val : valid[key]
        end
      end

      def setting_for(var)
        @vars.find_or_initialize_by(
          organization: @organization,
          var:
        )
      end

      # Checks if some var has been configured for the organization (not using defaults)
      def saved?(var)
        @saved_vars.include?(var.to_sym)
      end

      # Checks if some config setting is enabled in a certain context
      def enabled_in_context?(setting)
        config[setting]
      end

      # returns true if some setting is constrained in the current context
      # if no constraints defined, applies to everything
      def constrained_in_context?(setting)
        return true unless @vars.exists?(var: setting)

        @vars.where(var: setting).any? { |v| valid_in_context?(v.all_constraints) }
      end

      # checks if some constraint blocks the validity fot the current context
      def valid_in_context?(constraints)
        # if no constraints defined, applies to everything
        return true if constraints.blank?

        # if contains the "none" constraints, deactivate everything else
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

      # Merges all sub-configs values for custom_styles or any other scoped configs
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

        @sub_configs[singular_key] = config[plural_key].to_h do |key, _value|
          [key, AwesomeConfig.find_by(var: "#{singular_key}_#{key}", organization: @organization)]
        end
      end

      private

      def map_defaults
        defaults.to_h.to_h do |key, val|
          value = false
          unless val == :disabled
            value = yield(key, val)
            value = val.merge(value.transform_keys(&:to_sym)) if val.is_a?(Hash) && value.is_a?(Hash)
          end
          [key, value]
        end
      end

      # calculates the config according to the current context
      # - if some var is not valid in the current context, it will be nil
      # Certain keys may want to know if this is a legit value or it is simply not valid in the current context
      # Fot that, use the saved?(var) method
      def calculate_config
        # set values to vars according to the current context
        valid = @vars.to_h do |item|
          [
            item.var.to_sym,
            enabled_for_organization?(item.var) && valid_in_context?(item.all_constraints) ? item.value : nil
          ]
        end

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
