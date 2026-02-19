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
          %w(active past upcoming all)
        end

        def count_for(filter)
          case filter
          when "all"
            process_items.size
          else
            process_items.count { |item| item[:status] == filter }
          end
        end

        def taxonomy_filter_groups
          @taxonomy_filter_groups ||= build_taxonomy_filter_groups
        end

        def taxonomy_filters_available?
          taxonomy_filter_groups.any?
        end

        private

        def query
          @query ||= AwesomeProcessGroupsQuery.new(current_organization, current_user)
        end

        def build_taxonomy_filter_groups
          query.taxonomy_filters.map do |tf|
            items = tf.filter_items.map do |fi|
              taxonomy = fi.taxonomy_item
              { id: taxonomy.id, name: translated_attribute(taxonomy.name) }
            end
            next if items.empty?

            {
              id: tf.id,
              root_id: tf.root_taxonomy.id,
              name: translated_attribute(tf.root_taxonomy.name),
              items: items
            }
          end.compact
        end
      end
    end
  end
end
