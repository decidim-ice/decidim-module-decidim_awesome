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
          opts = [[t("any_group", scope: i18n_scope), 0]]
          groups.find_each do |group|
            opts << [translated_attribute(group.title), group.id]
          end
          opts
        end

        def selection_criteria_options
          [
            [t("selection_criteria_options.active", scope: i18n_scope), "active"],
            [t("selection_criteria_options.manual", scope: i18n_scope), "manual"]
          ]
        end

        def processes_for_select
          processes = published_processes.map do |process|
            ["##{process.id} - #{translated_attribute(process.title)}", "process_#{process.id}"]
          end

          groups = Decidim::ParticipatoryProcessGroup.where(organization: current_organization).map do |group|
            ["[#{t("group_label", scope: i18n_scope)}] #{translated_attribute(group.title)}", "group_#{group.id}"]
          end

          processes + groups
        end

        private

        def published_processes
          Decidim::ParticipatoryProcess.where(organization: current_organization).published
        end
      end
    end
  end
end
