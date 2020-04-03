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
          component_id: nil
        }
      end

      attr_reader :context

      def context=(context)
        @config = nil
        @context = context
      end

      def context_from_url(url); end

      def config
        @config ||= calculate_config
      end

      def unfiltered_config
        valid = @vars.map { |v| [v.var.to_sym, v.value] }.to_h
        Decidim::DecidimAwesome.config.map do |key, val|
          [key, valid[key].presence || val]
        end.to_h
      end

      # Checks if some config option es enabled in a certain context
      def enabled_for?(setting, *_context)
        # if context[:resource]
        # end

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
