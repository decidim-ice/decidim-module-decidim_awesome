# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class SpaceConstraintQuery
      SPACE_TYPES = {
        participatory_processes: "participatory_processes",
        assemblies: "assemblies",
        participatory_process_groups: "process_groups"
      }.freeze

      def initialize(organization:, space_type:, space:)
        @organization = organization
        @space_type = space_type
        @space = space
      end

      def call
        raise ArgumentError, "Invalid space_type: #{@space_type}" unless valid_space_type?

        query = base_query
        query = add_space_specific_conditions(query)
        query.exists?
      end

      private

      def base_query
        Decidim::DecidimAwesome::AwesomeConfig
          .where("var LIKE ?", "authorization_group_%")
          .where(organization: @organization)
          .joins(:constraints)
          .where("decidim_awesome_config_constraints.settings @> ?", { participatory_space_manifest: manifest_key }.to_json)
      end

      def add_space_specific_conditions(query)
        case @space_type
        when SPACE_TYPES[:participatory_processes], SPACE_TYPES[:assemblies]
          query.where(
            "(decidim_awesome_config_constraints.settings ->> 'participatory_space_slug' = ? OR " \
            "decidim_awesome_config_constraints.settings ->> 'participatory_space_slug' IS NULL)",
            @space.slug
          )
        when SPACE_TYPES[:participatory_process_groups]
          query.where(
            "(decidim_awesome_config_constraints.settings ->> 'participatory_space_id' = ? OR " \
            "decidim_awesome_config_constraints.settings ->> 'participatory_space_id' IS NULL)",
            @space.id.to_s
          )
        else
          query
        end
      end

      def manifest_key
        SPACE_TYPES[@space_type.to_sym] || @space_type
      end

      def valid_space_type?
        @space_type.present?
      end
    end
  end
end
