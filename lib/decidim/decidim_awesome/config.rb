# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    include ActiveSupport::Configurable

    config_accessor :allow_images_in_full_editor do
      false
    end

    config_accessor :allow_images_in_small_editor do
      false
    end

    config_accessor :allow_images_in_proposals do
      false
    end

    config_accessor :use_markdown_in_proposals do
      false
    end
  end
end
