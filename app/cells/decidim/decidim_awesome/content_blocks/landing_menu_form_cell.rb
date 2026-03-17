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

        def available_anchors
          @available_anchors ||= self.class.available_anchors_for(content_block)
        end

        # Shared with other components to avoid duplication
        def self.available_anchors_for(content_block)
          sibling_blocks = Decidim::ContentBlock.for_scope(
            content_block.scope_name, organization: content_block.organization
          ).where.not(
            id: content_block.id
          ).where.not(
            published_at: nil
          ).where.not(
            manifest_name: "awesome_landing_menu"
          )

          sibling_blocks.filter_map do |block|
            anchor = begin
              cell_instance = Decidim::ViewModel.cell(block.cell, block)
              cell_instance.send(:block_id)
            rescue NoMethodError
              nil
            rescue Cell::TemplateMissingError
              "awesome-content-block-#{block.manifest_name}-#{block.id}"
            end
            next if anchor.blank?

            label = I18n.t(block.manifest.public_name_key, default: block.manifest_name.humanize)
            { label:, anchor: }
          end
        end
      end
    end
  end
end
