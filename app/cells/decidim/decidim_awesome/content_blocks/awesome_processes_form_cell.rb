# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module ContentBlocks
      class AwesomeProcessesFormCell < Decidim::ViewModel
        alias form model

        def content_block
          options[:content_block]
        end

        def i18n_scope
          "decidim.decidim_awesome.content_blocks.awesome_processes"
        end

        def process_type_options
          [
            [t("process_types.all", scope: i18n_scope), "all"],
            [t("process_types.processes", scope: i18n_scope), "processes"],
            [t("process_types.groups", scope: i18n_scope), "groups"]
          ]
        end

        def process_group_options
          groups = Decidim::ParticipatoryProcessGroup.where(organization: current_organization)
          [[t("any_group", scope: i18n_scope), 0]] +
            groups.map { |group| [translated_attribute(group.title), group.id] }
        end

        def process_status_options
          [
            [t("process_statuses.active", scope: i18n_scope), "active"],
            [t("process_statuses.all", scope: i18n_scope), "all"],
            [t("process_statuses.upcoming", scope: i18n_scope), "upcoming"],
            [t("process_statuses.past", scope: i18n_scope), "past"]
          ]
        end

        def selection_criteria_options
          [
            [t("selection_criteria_options.automatic", scope: i18n_scope), "automatic"],
            [t("selection_criteria_options.manual", scope: i18n_scope), "manual"]
          ]
        end

        def processes_for_select
          reorder_by_saved_selection(build_process_options)
        end

        private

        def build_process_options
          published_processes.map do |process|
            label = translated_attribute(process.title)
            attrs = {
              "data-group-id" => process.decidim_participatory_process_group_id.to_i,
              "data-status" => process_status_for(process)
            }
            [label, process.id.to_s, attrs]
          end
        end

        # Puts selected items first in saved order so TomSelect initializes with correct ordering
        def reorder_by_saved_selection(all_options)
          saved_ids = Array(content_block&.settings&.selected_ids).compact_blank
          return all_options if saved_ids.empty?

          options_by_value = all_options.index_by { |_, val| val }
          saved_set = saved_ids.to_set
          selected = saved_ids.filter_map { |id| options_by_value[id] }
          unselected = all_options.reject { |_, val| saved_set.include?(val) }
          selected + unselected
        end

        def process_status_for(process)
          if process.upcoming?
            "upcoming"
          elsif process.past?
            "past"
          else
            "active"
          end
        end

        def published_processes
          Decidim::ParticipatoryProcesses::OrganizationPublishedParticipatoryProcesses
            .new(current_organization, current_user)
            .query
        end
      end
    end
  end
end
