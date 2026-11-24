# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # Keeps the extra tags of the HTML code editor in the content written by admins, only where the editor is enabled.
    module SanitizeHelperOverride
      def decidim_sanitize_admin(html, options = {})
        super(html, html_code_editor_scrubber.merge(options))
      end

      def decidim_sanitize_editor_admin(html, options = {})
        super(html, html_code_editor_scrubber.merge(options))
      end

      private

      # Mailers, presenters and services have no page to check the configuration against, they keep the Decidim rules.
      def html_code_editor_scrubber
        return {} unless respond_to?(:html_code_editor_tags?, true) && respond_to?(:request, true) && request
        return {} unless html_code_editor_tags?

        { scrubber: HtmlCodeEditorScrubber.new }
      end
    end
  end
end
