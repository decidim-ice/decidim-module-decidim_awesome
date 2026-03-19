# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module ContentBlocks
      class LandingMenuFormCell < Decidim::ViewModel
        include Cell::ViewModel::Partial

        alias form model

        def table
          render
        end

        def decidim_admin_decidim_awesome
          Decidim::DecidimAwesome::AdminEngine.routes.url_helpers
        end

        def content_block
          options[:content_block]
        end

        def i18n_scope
          "decidim.decidim_awesome.content_blocks.landing_menu"
        end

        def alignment_options
          %w(left center right).map do |value|
            [t("alignment_#{value}", scope: i18n_scope), value]
          end
        end

        def json_menu_items
          MenuItemsParser.parse_json(content_block.settings.menu_items)
        end
      end
    end
  end
end
