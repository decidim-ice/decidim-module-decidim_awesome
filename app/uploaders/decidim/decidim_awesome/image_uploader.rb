# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # This class deals with uploading images to a Blueprints.
    class ImageUploader < Decidim::ImageUploader
      process :validate_size, :validate_dimensions

      version :thumbnail do
        process resize_to_fit: [nil, 237]
      end

      def extension_white_list
        %w(jpg jpeg png)
      end

      def max_image_height_or_width
        8000
      end
    end
  end
end
