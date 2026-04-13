# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module ContentBlocks
      class RichTextCell < Decidim::ContentBlocks::BaseCell
        def show
          return if columns.empty?

          super
        end

        def block_id
          sanitize_id(model.settings.block_id).presence || "awesome-rich-text-#{model.id}"
        end

        def extra_classes
          "awesome-rich-text"
        end

        def i18n_scope
          "decidim.decidim_awesome.content_blocks.rich_text"
        end

        def title
          translated_attribute(model.settings.title).presence
        end

        def columns
          @columns ||= RichTextColumn.from_settings(model.settings.columns).select do |col|
            translated_attribute(col.body).present?
          end
        end

        def column_background_color(column)
          color = column.background_color.presence
          return unless color&.match?(/\A#(?:[0-9a-fA-F]{3}){1,2}\z/)

          color
        end

        def column_background_image(index)
          @column_background_images ||= {}
          @column_background_images[index] ||= model.images_container.attached_uploader(:"background_image_#{index}").url
        end

        def column_styles(column, index)
          color = column_background_color(column)
          image_url = column_background_image(index)

          styles = []
          styles << "--awesome-rich-text-bg: #{color}" if color
          if image_url.present?
            escaped_url = image_url.gsub("'", "%27").gsub(")", "%29")
            styles << "--awesome-rich-text-bg-image: url('#{escaped_url}')"
          end
          styles.join("; ")
        end

        def column_placement_class(column, index)
          return if column_background_image(index).blank?

          PLACEMENT_CLASSES[column.background_image_placement] || PLACEMENT_CLASSES["cover_center"]
        end

        def grid_class
          GRID_CLASSES[columns.size]
        end

        # Returns the rendered body HTML for a column, applying server-side
        # restrictions for non-authenticated users when configured.
        def rendered_body(column)
          html = decidim_sanitize_editor_admin(translated_attribute(column.body))
          return html if current_user

          html = strip_videos(html) if column.restrict_videos
          html = strip_links(html) if column.restrict_links
          html
        end

        GRID_CLASSES = {
          2 => "md:grid-cols-2",
          3 => "md:grid-cols-3",
          4 => "md:grid-cols-4",
          5 => "md:grid-cols-5"
        }.freeze

        PLACEMENT_CLASSES = {
          "cover_center" => "awesome-rich-text--bg-cover-center",
          "cover_top" => "awesome-rich-text--bg-cover-top",
          "cover_bottom" => "awesome-rich-text--bg-cover-bottom",
          "contain_center" => "awesome-rich-text--bg-contain-center",
          "repeat" => "awesome-rich-text--bg-repeat"
        }.freeze

        private

        def sanitize_id(value)
          return if value.blank?

          value.strip.downcase.gsub(/[^a-z0-9\-_]/, "-").gsub(/-{2,}/, "-").gsub(/\A-|-\z/, "")
        end

        def strip_videos(html)
          doc = Nokogiri::HTML::DocumentFragment.parse(html)
          message = t("sign_in_to_watch", scope: i18n_scope)

          doc.css("iframe, video, div.disabled-iframe").each do |node|
            placeholder = Nokogiri::XML::Node.new("button", doc.document)
            placeholder["type"] = "button"
            placeholder["data-dialog-open"] = "loginModal"
            placeholder["class"] = "awesome-rich-text__video-placeholder"
            placeholder.content = message
            node.replace(placeholder)
          end

          doc.to_html
        end

        def strip_links(html)
          doc = Nokogiri::HTML::DocumentFragment.parse(html)

          doc.css("a[href]").each do |link|
            link.remove_attribute("href")
            link["data-dialog-open"] = "loginModal"
          end

          doc.to_html
        end
      end
    end
  end
end
