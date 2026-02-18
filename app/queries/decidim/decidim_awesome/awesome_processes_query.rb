# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # Query class responsible for fetching participatory processes and/or groups
    # based on content block settings. Supports automatic (active) and manual selection.
    class AwesomeProcessesQuery
      def initialize(organization, current_user, settings)
        @organization = organization
        @current_user = current_user
        @settings = settings
      end

      def results
        case settings.selection_criteria
        when "manual"
          manual_selection
        else
          automatic_selection
        end
      end

      private

      attr_reader :organization, :current_user, :settings

      def automatic_selection
        return fetch_processes.first(max_results) if settings.process_type == "processes"
        return fetch_groups.first(max_results) if settings.process_type == "groups"

        interleave(fetch_processes, fetch_groups).first(max_results)
      end

      def manual_selection
        process_ids = []
        group_ids = []

        selected_ids.each do |id_str|
          type, id = id_str.split("_", 2)
          case type
          when "process" then process_ids << id.to_i
          when "group" then group_ids << id.to_i
          end
        end

        items_by_key = {}
        published_processes.where(id: process_ids).each { |p| items_by_key["process_#{p.id}"] = p } if process_ids.any?
        organization_groups.where(id: group_ids).each { |g| items_by_key["group_#{g.id}"] = g } if group_ids.any?

        selected_ids.filter_map { |id_str| items_by_key[id_str] }.first(max_results)
      end

      def fetch_processes
        scope = published_processes.active
        scope = scope.where(decidim_participatory_process_group_id: settings.process_group_id) if group_filter_active?
        scope.reorder(weight: :asc, id: :asc)
             .with_attached_hero_image
             .includes(:organization, :hero_image_attachment)
             .limit(max_results)
             .to_a
      end

      def fetch_groups
        scope = organization_groups
        scope = scope.where(id: settings.process_group_id) if group_filter_active?
        scope.order(promoted: :desc, id: :asc)
             .limit(max_results)
             .to_a
      end

      def published_processes
        Decidim::ParticipatoryProcesses::OrganizationPublishedParticipatoryProcesses
          .new(organization, current_user)
          .query
      end

      def organization_groups
        Decidim::ParticipatoryProcessGroup.where(organization: organization)
      end

      def group_filter_active?
        settings.process_group_id.to_i.positive?
      end

      def selected_ids
        settings.selected_ids.compact_blank
      end

      def max_results
        [settings.max_results.to_i, 0].max
      end

      # Alternates items from two arrays: [a1, b1, a2, b2, ...].
      # When one array is exhausted, appends remaining items from the other.
      def interleave(arr_a, arr_b)
        result = []
        max_len = [arr_a.size, arr_b.size].max
        max_len.times do |i|
          result << arr_a[i] if i < arr_a.size
          result << arr_b[i] if i < arr_b.size
        end
        result
      end
    end
  end
end
