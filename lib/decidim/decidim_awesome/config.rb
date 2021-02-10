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
          participatory_slug: nil,
          component_id: nil,
          component_manifest: nil
        }
      end

      attr_reader :context
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

        map_defaults do |key|
          valid[key].presence
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

        # check if current context matches some constraint
        constraints.detect do |constraint|
          # if some setting is different, rejects
          invalid = constraint.settings.detect { |key, val| context[key.to_sym] != val }
          invalid.blank?
        end
      end

      private

      def map_defaults
        defaults.map do |key, val|
          value = false
          unless val == :disabled
            value = yield(key) || val
            value = val.merge(value.transform_keys(&:to_sym)) if val.is_a? Hash
          end
          [key, value]
        end.to_h
      end

      def calculate_config
        # filter vars compliant with current context
        valid = @vars.filter { |item| enabled_for_organization?(item.var) && valid_in_context?(item.constraints) }
                     .map { |v| [v.var.to_sym, v.value] }.to_h

        map_defaults do |key|
          valid[key].presence
        end
      end

      # extra checks that may be relevant for the key
      def enabled_for_organization?(key)
        case key.to_sym
        when :allow_images_in_proposals
          if @organization.respond_to? :rich_text_editor_in_public_views
            return false if @organization.rich_text_editor_in_public_views
          end
        end
        true
      end
    end
  end
end
