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

      def config
        @config ||= calculate_config
      end

      def unfiltered_config
        valid = @vars.map { |v| [v.var.to_sym, v.value] }.to_h
        Decidim::DecidimAwesome.config.map do |key, val|
          [key, valid[key].presence || val]
        end.to_h
      end

      def setting_for(setting)
        @vars.find_or_initialize_by(
          organization: @organization,
          var: setting
        )
      end

      # Checks if some config option es enabled in a certain context
      def enabled_for?(setting)
        config[setting]
      end

      private

      def calculate_config
        # filter vars compliant with current context
        valid = @vars.filter { |item| valid_in_context?(item.constraints) }
                     .map { |v| [v.var.to_sym, v.value] }.to_h
        @config = Decidim::DecidimAwesome.config.map do |key, val|
          [key, valid[key].presence || val]
        end.to_h
      end

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
    end
  end
end
