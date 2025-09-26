# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class SpaceConstraintFinder
      def initialize(config_var, participatory_space)
        @config_var = config_var
        @participatory_space = participatory_space
      end

      attr_reader :participatory_space, :config_var

      def query
        return Decidim::DecidimAwesome::AwesomeConfig.none if participatory_space.nil?

        set_base_query
        add_space_specific_conditions
      end

      private

      def set_base_query
        @query = Decidim::DecidimAwesome::AwesomeConfig
                 .where("var LIKE ?", "#{config_var}_%")
                 .where(organization: participatory_space.organization)
                 .joins(:constraints)
                 .where("decidim_awesome_config_constraints.settings @> ?", { participatory_space_manifest: manifest_key }.to_json)
      end

      def add_space_specific_conditions
        @query.where(
          "(decidim_awesome_config_constraints.settings ->> 'participatory_space_slug' = ? OR " \
          "decidim_awesome_config_constraints.settings ->> 'participatory_space_slug' IS NULL)",
          participatory_space.try(:slug) || participatory_space.id.to_s
        )
      end

      def manifest_key
        return participatory_space.manifest.name if participatory_space.respond_to?(:manifest)

        :process_groups
      end
    end
  end
end
