# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module AdminInputScrubberOverride
      private

      def custom_allowed_tags
        super + extra_allowed_tags
      end

      def extra_allowed_tags
        Decidim::DecidimAwesome.html_code_editor_allowed_tags.map(&:to_s)
      end
    end
  end
end
