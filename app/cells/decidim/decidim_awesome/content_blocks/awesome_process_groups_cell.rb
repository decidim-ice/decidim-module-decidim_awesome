# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module ContentBlocks
      class AwesomeProcessGroupsCell < Decidim::ViewModel
        include Decidim::CardHelper

        def show
          render if process_items.any?
        end

        def process_items
          @process_items ||= query.results
        end

        def title
          translated_attribute(model.settings.title).presence || t("name", scope: i18n_scope)
        end

        def i18n_scope
          "decidim.decidim_awesome.content_blocks.awesome_process_groups"
        end

        def status_filters
          %w(active past all)
        end

        def count_for(filter)
          case filter
          when "active"
            process_items.count { |item| item[:status] == "active" }
          when "past"
            process_items.count { |item| item[:status] == "past" }
          else
            process_items.size
          end
        end

        private

        def query
          @query ||= AwesomeProcessGroupsQuery.new(current_organization)
        end
      end
    end
  end
end
