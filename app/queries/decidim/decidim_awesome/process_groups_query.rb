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

      def used_taxonomy_ids
        @used_taxonomy_ids ||= Decidim::Taxonomization
                               .where(taxonomizable_type: "Decidim::ParticipatoryProcess", taxonomizable_id: base_relation.select(:id))
                               .distinct
                               .pluck(:taxonomy_id)
                               .to_set
      end

      # Returns taxonomy groups with raw taxonomy objects, filtered to only
      # include items used by processes in the group, and sorted hierarchically.
      # Each group: { root_taxonomy:, items: [{ taxonomy:, depth: }] }
      def available_taxonomy_groups
        @available_taxonomy_groups ||= build_taxonomy_groups
      end

      private

      attr_reader :group, :user

      # -- Process filtering --

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
          scope = scope.where(id: taxonomizable_ids_for(ids))
        end

        scope
      end

      def taxonomizable_ids_for(taxonomy_ids)
        Decidim::Taxonomization
          .where(taxonomizable_type: "Decidim::ParticipatoryProcess", taxonomy_id: taxonomy_ids)
          .select(:taxonomizable_id)
      end

      # Groups selected IDs by root taxonomy using eager-loaded filter data.
      def group_taxonomy_ids_by_root(taxonomy_ids)
        id_set = taxonomy_ids.to_set
        taxonomy_filters.each_with_object({}) do |filter, groups|
          filter.filter_items.each do |item|
            (groups[filter.root_taxonomy_id] ||= []) << item.taxonomy_item_id if id_set.include?(item.taxonomy_item_id)
          end
        end
      end

      # -- Taxonomy group building --

      def build_taxonomy_groups
        grouped = {}

        taxonomy_filters.each do |tf|
          root = tf.root_taxonomy
          grouped[root.id] ||= { root_taxonomy: root, items: [] }

          tf.filter_items.each do |fi|
            taxonomy = fi.taxonomy_item
            depth = taxonomy.parent_id == root.id ? 0 : 1
            grouped[root.id][:items] << { taxonomy: taxonomy, depth: depth }
          end
        end

        grouped.values
               .each { |gr| gr[:items].uniq! { |it| it[:taxonomy].id } }
               .each { |gr| filter_unused_items!(gr[:items]) }
               .each { |gr| sort_items_hierarchically!(gr[:items]) }
               .reject { |gr| gr[:items].empty? }
      end

      # Keeps items used by processes + parent items needed for hierarchy.
      def filter_unused_items!(items)
        used_children = items.select { |it| it[:depth].positive? && used_taxonomy_ids.include?(it[:taxonomy].id) }
        kept_parent_ids = used_children.to_set { |it| it[:taxonomy].parent_id }

        items.select! do |item|
          tid = item[:taxonomy].id
          if item[:depth].positive?
            used_taxonomy_ids.include?(tid)
          else
            used_taxonomy_ids.include?(tid) || kept_parent_ids.include?(tid)
          end
        end
      end

      def sort_items_hierarchically!(items)
        children_by_parent = items.select { |it| it[:depth].positive? }.group_by { |it| it[:taxonomy].parent_id }
        top_level = items.select { |it| it[:depth].zero? }

        items.replace(
          top_level.flat_map { |parent| [parent, *children_by_parent.fetch(parent[:taxonomy].id, [])] }
        )
      end
    end
  end
end
