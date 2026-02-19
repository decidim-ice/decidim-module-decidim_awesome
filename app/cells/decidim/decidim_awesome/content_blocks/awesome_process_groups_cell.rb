# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module ContentBlocks
      class AwesomeProcessGroupsCell < Decidim::ViewModel
        include Decidim::CardHelper

        def show
          render if processes.any?
        end

        def processes
          @processes ||= Decidim::ParticipatoryProcess
                         .where(organization: current_organization)
                         .published
                         .where.not(decidim_participatory_process_group_id: nil)
                         .order(weight: :asc, start_date: :desc)
        end

        def title
          translated_attribute(model.settings.title).presence || t("name", scope: i18n_scope)
        end

        def i18n_scope
          "decidim.decidim_awesome.content_blocks.awesome_process_groups"
        end
      end
    end
  end
end
