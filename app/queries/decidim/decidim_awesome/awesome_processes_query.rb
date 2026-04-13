# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # Query class responsible for fetching participatory processes
    # based on content block settings.
    #
    # Process types:
    #   - "processes": only processes WITHOUT a group
    #   - "groups": only processes WITH a group (optionally restricted to a specific group)
    #   - "all": all processes regardless of group membership
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

      def process_status
        settings.respond_to?(:process_status) ? settings.process_status : "active"
      end

      def automatic_selection
        fetch_processes
      end

      def manual_selection
        ids = selected_process_ids
        return [] if ids.empty?

        scope = published_processes.where(id: ids).includes(:organization, :hero_image_attachment)
        scope = apply_type_filter(scope)
        scope = apply_group_filter(scope)

        items_by_id = scope.index_by(&:id)
        ids.filter_map { |id| items_by_id[id] }.first(max_results)
      end

      def fetch_processes
        scope = published_processes
        scope = apply_status_filter(scope)
        scope = apply_type_filter(scope)
        scope = apply_group_filter(scope)
        scope.reorder(weight: :asc, id: :asc)
             .includes(:organization, :hero_image_attachment)
             .limit(max_results)
             .to_a
      end

      def apply_status_filter(scope)
        case process_status
        when "all" then scope
        when "upcoming" then scope.upcoming
        when "past" then scope.past
        else scope.active
        end
      end

      def apply_type_filter(scope)
        case settings.process_type
        when "processes"
          scope.where(decidim_participatory_process_group_id: nil)
        when "groups"
          scope.where.not(decidim_participatory_process_group_id: nil)
        else
          scope
        end
      end

      # When type = "all", restrict applies only to grouped processes — ungrouped always pass
      # When type = "processes", group filter is irrelevant (ungrouped processes have no group)
      def apply_group_filter(scope)
        return scope unless group_filter_active?
        return scope if settings.process_type == "processes"

        if settings.process_type == "all"
          scope.where(decidim_participatory_process_group_id: [settings.process_group_id, nil])
        else
          scope.where(decidim_participatory_process_group_id: settings.process_group_id)
        end
      end

      def published_processes
        Decidim::ParticipatoryProcesses::OrganizationPublishedParticipatoryProcesses
          .new(organization, current_user)
          .query
      end

      def group_filter_active?
        settings.process_group_id.to_i.positive?
      end

      def selected_process_ids
        settings.selected_ids.compact_blank.map(&:to_i).reject(&:zero?)
      end

      def max_results
        [settings.max_results.to_i, 1].max
      end
    end
  end
end
