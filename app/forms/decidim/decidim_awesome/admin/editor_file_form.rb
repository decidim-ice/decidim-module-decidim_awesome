# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class EditorFileForm < Decidim::Form
        mimic :editor_file

        attribute :file
        attribute :author_id, Integer
        attribute :path, String

        validates :author_id, presence: true
        validates :file, presence: true
        validates :file, passthru: { to: Decidim::DecidimAwesome::EditorFile }
        validate :content_types_allowed

        alias organization current_organization

        private

        # An empty allowlist means no validation for the uploader, here it means that uploads are turned off.
        def content_types_allowed
          return if EditorFile.new(organization:).attached_uploader(:file).content_type_allowlist.any?

          errors.add(:file, :invalid)
        end
      end
    end
  end
end
