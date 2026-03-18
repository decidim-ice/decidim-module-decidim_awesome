# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      module LandingMenuItemPresetBuilder
        extend ActiveSupport::Concern

        included do
          helper_method :landing_menu_item_presets_options
        end

        private

        def with_available_locales
          ([current_organization.default_locale] + current_organization.available_locales).uniq.each do |locale|
            I18n.with_locale(locale) { yield locale }
          end
        end

        def landing_menu_item_presets_options(block_scope:)
          @landing_menu_item_presets_options ||= [
            [I18n.t("decidim.decidim_awesome.admin.landing_menu_items.form.preset_global_menu"), global_menu_presets],
            [I18n.t("decidim.decidim_awesome.admin.landing_menu_items.form.preset_content_blocks"), content_block_presets(block_scope)]
          ]
        end

        def content_block_presets(block_scope)
          items = {}
          with_available_locales do |locale|
            available_anchors_for(block_scope).map do |item|
              label = I18n.t(item[:key], default: item[:manifest])
              items[item[:anchor]] ||= items[item[:anchor]] || [label, item[:anchor], {}]
              items[item[:anchor]][2]["data-label-#{locale}"] = label
            end
          end
          items.values
        end

        # Shared with other components to avoid duplication
        def available_anchors_for(block_scope)
          sibling_blocks = Decidim::ContentBlock.for_scope(
            block_scope, organization: current_organization
          ).published.where.not(
            manifest_name: "awesome_landing_menu"
          )

          sibling_blocks.filter_map do |block|
            anchor = ParseContentBlock.new(cell(block.cell, block)).id
            next unless anchor

            { key: block.manifest.public_name_key, manifest: block.manifest_name.humanize, anchor: "##{anchor}" }
          end
        end

        def global_menu_presets
          items = {}
          with_available_locales do |locale|
            build_global_menu.items.sort_by(&:position).map do |item|
              url = item.url.to_s.split("?").first
              items[url] ||= items[url] || [item.label, url, {}]
              items[url][2]["data-label-#{locale}"] = item.label
            end
          end
          items.values
        end

        def build_global_menu
          menu = Decidim::Menu.new(:menu)
          menu.build_for(self)
          menu
        end
      end
    end
  end
end
