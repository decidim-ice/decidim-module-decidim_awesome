# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module OverviewComponent
      # Custom helpers for overview cells.
      #
      module OverviewCellsHelper
        def i18n_scope
          "decidim.components.awesome_overview.components.#{type}"
        end

        def items_count_title
          t("#{i18n_scope}.items_count", count: items.count)
        end

        def items_tooltip
          t("#{i18n_scope}.items_tooltip")
        end

        def items_count_status
          link_to resource_path, "aria-label" => items_count_title, title: items_count_title do
            render_items_count
          end
        end

        def render_items_count
          with_tooltip items_tooltip do
            items_count_title
          end
        end
      end
    end
  end
end
