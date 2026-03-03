# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module ContentBlocks
      class AwesomeProcessGroupsCell < Decidim::ContentBlocks::BaseCell
        include Decidim::CardHelper
        include Decidim::CellsPaginateHelper
        include Decidim::ParticipatoryProcesses::Engine.routes.url_helpers

        def show
          return unless resource

          render if query.base_relation.exists?
        end

        def title
          translated_attribute(model.settings.title).presence || t("default_title", scope: i18n_scope)
        end

        def i18n_scope
          "decidim.decidim_awesome.content_blocks.awesome_process_groups"
        end

        def max_count
          [model.settings&.max_count.to_i, 1].max
        end

        def block_id
          "awesome-process-groups-#{model.id}"
        end

        def data
          { "process-groups-filter": "" }
        end

        def status_filters
          %w(active past upcoming all)
        end

        def current_status
          @current_status ||= params[:status].in?(%w(active past upcoming)) ? params[:status] : "all"
        end

        def selected_taxonomy_ids
          @selected_taxonomy_ids ||= Array(params[:taxonomy_ids]).map(&:to_i).reject(&:zero?).uniq
        end

        def current_page
          @current_page ||= [params[:page].to_i, 1].max
        end

        def taxonomy_selected?(id)
          selected_taxonomy_ids.include?(id)
        end

        def filter_url(overrides = {})
          status = overrides.fetch(:status, current_status)
          url_params = {}
          url_params[:status] = status unless status == "all"
          url_params[:taxonomy_ids] = selected_taxonomy_ids if selected_taxonomy_ids.any?
          url_params.merge!(overrides.except(:status))
          participatory_process_group_path(resource, **url_params)
        end

        def paginated_items
          @paginated_items ||= query.filtered_relation(
            status: current_status,
            taxonomy_ids: selected_taxonomy_ids
          ).page(current_page).per(max_count)
        end

        # Counts always reflect the full group (not affected by taxonomy selection).
        def count_for(filter)
          query.status_counts[filter] || 0
        end

        def taxonomy_filter_groups
          @taxonomy_filter_groups ||= build_taxonomy_filter_groups
        end

        def taxonomy_filters_available?
          taxonomy_filter_groups.any?
        end

        def selected_taxonomy_tags
          @selected_taxonomy_tags ||= begin
            all_items = taxonomy_filter_groups.flat_map { |group| group[:items] }
            selected_taxonomy_ids.filter_map { |taxonomy_id| all_items.find { |item| item[:id] == taxonomy_id } }
          end
        end

        private

        def query
          @query ||= ProcessGroupsQuery.new(resource, current_user)
        end

        def pagination_params
          result = {}
          result[:status] = current_status unless current_status == "all"
          result[:taxonomy_ids] = selected_taxonomy_ids if selected_taxonomy_ids.any?
          result
        end

        def build_taxonomy_filter_groups
          query.available_taxonomy_groups.map do |group|
            root = group[:root_taxonomy]
            {
              root_id: root.id,
              name: translated_attribute(root.name),
              items: group[:items].map do |item|
                tx = item[:taxonomy]
                { id: tx.id, name: translated_attribute(tx.name), parent_id: tx.parent_id, depth: item[:depth] }
              end
            }
          end
        end
      end
    end
  end
end
