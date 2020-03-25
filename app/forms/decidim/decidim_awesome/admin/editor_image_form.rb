# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class EditorImageForm < Decidim::Form
        mimic :editor_image

        attribute :image
        attribute :author_id, Integer
        attribute :path, String

        validates :author_id, presence: true
      end
    end
  end
end
