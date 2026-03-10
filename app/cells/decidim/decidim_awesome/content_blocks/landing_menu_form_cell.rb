# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module ContentBlocks
      class LandingMenuFormCell < Decidim::ViewModel
        alias form model

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

        def available_anchors
          @available_anchors ||= sibling_blocks.filter_map do |block|
            label = I18n.t(block.manifest.public_name_key, default: block.manifest_name.humanize)
            anchor = anchor_for(block)
            { label:, anchor: }
          end
        end

        private

        def sibling_blocks
          Decidim::ContentBlock
            .for_scope(content_block.scope_name, organization: content_block.organization)
            .where.not(id: content_block.id)
            .where.not(published_at: nil)
            .where.not(manifest_name: "awesome_landing_menu")
        end

        def anchor_for(block)
          cell_instance = cell(block.cell, block)
          cell_instance.block_id
        rescue StandardError
          "awesome-content-block-#{block.manifest_name}-#{block.id}"
        end
      end
    end
  end
end
