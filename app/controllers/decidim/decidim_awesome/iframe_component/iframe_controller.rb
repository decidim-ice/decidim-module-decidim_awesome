# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module IframeComponent
      class IframeController < DecidimAwesome::BlankComponentController
        ALLOWED_ATTRIBUTES = %w(src width height frameborder title allow allowpaymentrequest name referrerpolicy sandbox srcdoc allowfullscreen).freeze
        helper_method :iframe, :viewport_width?
        before_action :add_additional_csp_directives, only: :show

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

        def viewport_width?
          current_component.settings.viewport_width
        end

        def add_additional_csp_directives
          iframe_urls = Nokogiri::HTML::DocumentFragment.parse(iframe).children.select { |x| x.name == "iframe" }.filter_map { |x| x.attribute("src")&.value }
          return if iframe_urls.blank?

          iframe_urls.each do |url|
            content_security_policy.append_csp_directive("frame-src", url)
          end
        end
      end
    end
  end
end
