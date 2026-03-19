# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module ContentBlocks
      class RichTextFormCell < Decidim::ViewModel
        alias form model

        def content_block
          options[:content_block]
        end

        def decidim_admin_decidim_awesome
          Decidim::DecidimAwesome::AdminEngine.routes.url_helpers
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

        def column_fields(col_fields, column, column_id)
          @col_fields = col_fields
          @column = column
          @column_id = column_id
          render :column_fields
        end

        def column_extra_fields(col_fields, column_id, images_fields, image_field_name)
          @col_fields = col_fields
          @column_id = column_id
          @images_fields = images_fields
          @image_field_name = image_field_name.to_sym
          render :column_extra_fields
        end

        def block_id_for_css
          content_block&.settings&.block_id.presence || "your-block-id"
        end

        def placement_options
          RichTextColumn::PLACEMENT_OPTIONS.map do |key|
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
