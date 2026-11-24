# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # This class deals with the files uploaded by admins from the HTML code editor.
    class EditorFileUploader < Decidim::AttachmentUploader
      # Content types configured in the module that the organization also accepts from admins.
      def content_type_allowlist
        organization_types = super

        Decidim::DecidimAwesome.html_code_editor_allowed_mime.map(&:to_s).select do |type|
          organization_types.any? { |allowed| allowed.match?(type) }
        end
      end

      # Extensions of the allowed content types, with the aliases the organization accepts (jpg for jpeg).
      def extension_allowlist
        types = content_type_allowlist
        aliases = super.select { |extension| types.include?(MiniMime.lookup_by_extension(extension)&.content_type) }

        types.filter_map { |type| MiniMime.lookup_by_content_type(type)&.extension } | aliases
      end

      protected

      def upload_context
        :admin
      end
    end
  end
end
