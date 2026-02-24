# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # Provides filtered and counted queries for processes within a group.
    class ProcessGroupsQuery
      def initialize(group, user = nil)
        @group = group
        @user = user
      end

      def base_relation
        @base_relation ||=
          Decidim::ParticipatoryProcesses::GroupPublishedParticipatoryProcesses
          .new(group, user).query
          .includes(:organization, :taxonomies, :active_step, :hero_image_attachment)
          .order(weight: :asc, start_date: :desc)
      end

      def filtered_relation(status: "all", taxonomy_ids: [])
        scope = filter_by_status(base_relation, status)
        filter_by_taxonomies(scope, taxonomy_ids)
      end

      # Unfiltered counts so tab numbers stay stable regardless of active filters.
      def status_counts
        @status_counts ||= {
          "active" => base_relation.active.count,
          "past" => base_relation.past.count,
          "upcoming" => base_relation.upcoming.count,
          "all" => base_relation.count
        }
      end

      def taxonomy_filters
        @taxonomy_filters ||= Decidim::TaxonomyFilter
                              .for(group.organization)
                              .for_manifest(:participatory_processes)
                              .includes(:root_taxonomy, filter_items: :taxonomy_item)
      end

      private

      attr_reader :group, :user

      def filter_by_status(scope, status)
        case status
        when "active" then scope.active
        when "past" then scope.past
        when "upcoming" then scope.upcoming
        else scope
        end
      end

      # AND between root taxonomy groups, OR within each group.
      def filter_by_taxonomies(scope, taxonomy_ids)
        taxonomy_ids = Array(taxonomy_ids).map(&:to_i).reject(&:zero?).uniq
        return scope if taxonomy_ids.empty?

        group_taxonomy_ids_by_root(taxonomy_ids).each_value do |ids|
          scope = scope.where(id: process_ids_with_taxonomies(ids))
        end

        scope
      end

      def process_ids_with_taxonomies(taxonomy_ids)
        Decidim::Taxonomization
          .where(taxonomizable_type: "Decidim::ParticipatoryProcess", taxonomy_id: taxonomy_ids)
          .select(:taxonomizable_id)
      end

      # Groups selected taxonomy IDs by their root taxonomy.
      # Example: { root_1_id => [child_a, child_b], root_2_id => [child_c] }
      def group_taxonomy_ids_by_root(taxonomy_ids)
        mapping = build_taxonomy_to_root_mapping

        taxonomy_ids.each_with_object({}) do |taxonomy_id, groups|
          root_id = mapping[taxonomy_id]
          next unless root_id

          (groups[root_id] ||= []) << taxonomy_id
        end
      end

      # Builds { taxonomy_item_id => root_taxonomy_id } from available filters.
      def build_taxonomy_to_root_mapping
        taxonomy_filters.each_with_object({}) do |filter, mapping|
          root_id = filter.root_taxonomy_id
          filter.filter_items.each { |item| mapping[item.taxonomy_item_id] = root_id }
        end
      end
    end
  end
end
