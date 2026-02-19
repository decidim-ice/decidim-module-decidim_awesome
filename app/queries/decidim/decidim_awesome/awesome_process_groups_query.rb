# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class AwesomeProcessGroupsQuery
      def initialize(organization, user = nil)
        @organization = organization
        @user = user
      end

      def results
        @results ||= base_relation.map do |process|
          {
            process: process,
            status: status_for(process),
            taxonomy_ids: process.taxonomy_ids
          }
        end
      end

      def taxonomy_filters
        @taxonomy_filters ||= Decidim::TaxonomyFilter
                              .for(organization)
                              .for_manifest(:participatory_processes)
                              .includes(:root_taxonomy, filter_items: :taxonomy_item)
      end

      private

      attr_reader :organization, :user

      def base_relation
        @base_relation ||=
          Decidim::ParticipatoryProcesses::OrganizationPublishedParticipatoryProcesses
          .new(organization, user).query
          .grouped
          .includes(:organization, :taxonomies)
          .with_attached_hero_image
          .order(weight: :asc, start_date: :desc)
      end

      # Upcoming and undated processes fall through to "active" by design:
      # the UI only has Active/Past filters, and non-past processes are
      # shown under "Active" as the expected default.
      def status_for(process)
        return "active" if process.active?
        return "past" if process.past?

        "active"
      end
    end
  end
end
