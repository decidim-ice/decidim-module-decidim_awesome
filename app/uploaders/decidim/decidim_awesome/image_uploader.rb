# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # This class deals with uploading images to a Blueprints.
    class ImageUploader < Decidim::ImageUploader
      set_variants do
        {
          thumbnail: { resize_to_fit: [nil, 237] }
        }
      end

      def extension_allowlist
        %w(jpg jpeg png)
      end

      def content_type_allowlist
        %w(image/jpeg image/png)
      end

      def max_image_height_or_width
        8000
      end
    end
  end
end
