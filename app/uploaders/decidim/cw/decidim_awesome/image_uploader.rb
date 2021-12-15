# frozen_string_literal: true

module Decidim::Cw
  module DecidimAwesome
    # This class deals with uploading images to a Blueprints.
    class ImageUploader < Decidim::Cw::ImageUploader
      process :validate_size, :validate_dimensions

      version :thumbnail do
        process resize_to_fit: [nil, 237]
      end

      def extension_whitelist
        %w(jpg jpeg png)
      end

      def content_type_whitelist
        %w(image/jpeg image/png)
      end

      def max_image_height_or_width
        8000
      end
    end
  end
end
