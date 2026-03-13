# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module ContentBlocks
      class RichTextFormCell < Decidim::ViewModel
        alias form model

        def content_block
          options[:content_block]
        end

        def i18n_scope
          "decidim.decidim_awesome.content_blocks.rich_text"
        end

        def column_objects
          @column_objects ||= RichTextColumn.from_settings(content_block&.settings&.columns)
        end

        def blank_column
          @blank_column ||= RichTextColumn.new
        end

        def max_columns
          Decidim::DecidimAwesome.max_rich_text_columns
        end

        def placement_options
          %w(cover_center cover_top cover_bottom contain_center repeat).map do |key|
            [t("background_image_placements.#{key}", scope: i18n_scope), key]
          end
        end

        def default_block_id
          return content_block.settings.block_id if content_block&.settings&.block_id.present?

          existing = Decidim::ContentBlock.where(
            decidim_organization_id: content_block&.organization&.id,
            manifest_name: "awesome_rich_text"
          ).count
          "awesome-rich-text-#{existing + 1}"
        end
      end
    end
  end
end
