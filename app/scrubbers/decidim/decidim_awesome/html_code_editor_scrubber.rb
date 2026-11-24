# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # Sanitizes the admin content where the HTML code editor is enabled, keeping the extra tags configured for it.
    class HtmlCodeEditorScrubber < Decidim::AdminInputScrubber
      private

      def custom_allowed_tags
        super + Decidim::DecidimAwesome.html_code_editor_allowed_tags.map(&:to_s)
      end
    end
  end
end
