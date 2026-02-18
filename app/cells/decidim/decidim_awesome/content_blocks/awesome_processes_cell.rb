# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module ContentBlocks
      class AwesomeProcessesCell < Decidim::ContentBlocks::HighlightedParticipatorySpacesCell
        def highlighted_spaces
          @highlighted_spaces ||= query.results
        end

        alias limited_highlighted_spaces highlighted_spaces

        def i18n_scope
          "decidim.decidim_awesome.content_blocks.awesome_processes"
        end

        def all_path
          Decidim::ParticipatoryProcesses::Engine.routes.url_helpers.participatory_processes_path
        end

        def max_results
          model.settings.max_results
        end

        def title
          translated_attribute(model.settings.title).presence
        end

        private

        def block_id
          "awesome-processes"
        end

        def query
          @query ||= AwesomeProcessesQuery.new(
            current_organization,
            current_user,
            model.settings
          )
        end
      end
    end
  end
end
