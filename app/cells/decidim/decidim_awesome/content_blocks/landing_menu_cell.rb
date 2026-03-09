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
          @menu_items ||= parse_menu_items(translated_attribute(model.settings.menu_items))
        end

        def sticky?
          model.settings.sticky
        end

        def alignment
          model.settings.alignment.presence || "center"
        end

        def justify_class
          case alignment
          when "left" then "justify-start"
          when "right" then "justify-end"
          else "justify-center"
          end
        end

        def block_id
          "awesome-landing-menu-#{model.id}"
        end

        def i18n_scope
          "decidim.decidim_awesome.content_blocks.landing_menu"
        end

        private

        def parse_menu_items(text)
          return [] if text.blank?

          text.lines.filter_map do |line|
            parts = line.strip.split("|").map(&:strip)
            next if parts.length < 2 || parts[0].blank? || parts[1].blank?

            { label: parts[0], url: parts[1], target: parts[2].presence }
          end
        end
      end
    end
  end
end
