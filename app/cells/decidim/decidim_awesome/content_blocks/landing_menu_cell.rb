# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module ContentBlocks
      class LandingMenuCell < Decidim::ContentBlocks::BaseCell
        def show
          return if menu_items.empty?

          render
        end

        def menu_items
          @menu_items ||= parse_menu_items(model.settings.menu_items).select { |item| item[:visible] }
        end

        def sticky?
          model.settings.sticky
        end

        def alignment
          model.settings.alignment.presence || "center"
        end

        def show_on_mobile?
          model.settings.show_on_mobile
        end

        def block_id
          "awesome-landing-menu-#{model.id}"
        end

        def i18n_scope
          "decidim.decidim_awesome.content_blocks.landing_menu"
        end

        private

        def parse_menu_items(raw)
          MenuItemsParser.parse_json(raw).filter_map { |item| build_menu_item(item) }
        end

        def build_menu_item(item)
          return unless item.is_a?(Hash) && item["url"].present?

          label = translated_attribute(item["name"])
          return if label.blank?

          url = item["url"]
          return unless url.match?(MenuItemsParser::SAFE_URL_PATTERN)

          target = url.match?(%r{\Ahttps://}i) ? "_blank" : nil
          visible = item.fetch("visible", true) != false

          { label:, url:, target:, visible: }
        end
      end
    end
  end
end
