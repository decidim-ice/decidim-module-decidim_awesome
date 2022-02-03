# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class EditorImageForm < Decidim::Form
      mimic :editor_image

      attribute :file
      attribute :author_id, Integer
      attribute :path, String

      validates :author_id, presence: true
      validates :file, presence: true
      validates :file, passthru: { to: Decidim::DecidimAwesome::EditorImage }

      alias organization current_organization
    end
  end
end
