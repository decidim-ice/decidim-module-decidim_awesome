# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module IframeComponent
      class IframeController < DecidimAwesome::BlankComponentController
        ALLOWED_ATTRIBUTES = %w(src width height frameborder title allow allowpaymentrequest name referrerpolicy sandbox srcdoc allowfullscreen).freeze
        helper_method :iframe, :remove_margins?, :viewport_width?

        def show; end

        private

        def iframe
          @iframe ||= sanitize(current_component.settings.iframe).html_safe
        end

        def sanitize(html)
          sanitizer = Rails::Html::SafeListSanitizer.new
          partially_sanitized_html = sanitizer.sanitize(html, tags: %w(iframe), attributes: ALLOWED_ATTRIBUTES)

          document = Nokogiri::HTML::DocumentFragment.parse(partially_sanitized_html)
          document.css("iframe").each do |iframe|
            iframe["srcdoc"] = Loofah.fragment(iframe["srcdoc"]).scrub!(:prune).to_s if iframe["srcdoc"]
          end

          document.to_s
        end

        def remove_margins?
          current_component.settings.no_margins
        end

        def viewport_width?
          current_component.settings.viewport_width
        end
      end
    end
  end
end
