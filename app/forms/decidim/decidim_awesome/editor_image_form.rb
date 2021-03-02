# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class EditorImageForm < Decidim::Form
      mimic :editor_image

      attribute :image
      attribute :author_id, Integer
      attribute :path, String

      validates :author_id, presence: true
      validates :image, presence: true

      alias organization current_organization
    end
  end
end
