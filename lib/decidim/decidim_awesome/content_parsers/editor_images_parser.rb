# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module ContentParsers
      # A parser that searches for editor images from CarrierWave in html
      # contents and replaces them with migrated images to ActiveStorage
      #
      # @see BaseParser Examples of how to use a content parser
      class EditorImagesParser < Decidim::ContentParsers::BaseParser
        # @return [String] the content with the CarrierWave images replaced.
        def rewrite
          return content if editor_images.blank?

          replace_editor_images
          parsed_content.to_html
        end

        def editor_images
          @editor_images ||= parsed_content.search(:img).index_with do |image|
            context[:routes_mappings].find { |mapping| image.attr(:src).end_with?(mapping[:origin_path]) }
          end.compact
        end

        private

        def parsed_content
          @parsed_content ||= Nokogiri::HTML(content)
        end

        def replace_editor_images
          editor_images.each do |image, mapping|
            image.set_attribute(:src, mapping[:instance].attached_uploader(:image).path)
          end
        end
      end
    end
  end
end
