# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module IframeComponent
      class IframeController < DecidimAwesome::IframeComponent::ApplicationController
        ALLOWED_ATTRIBUTES = %w(src width height frameborder title allow allowpaymentrequest name referrerpolicy sandbox srcdoc allowfullscreen).freeze
        helper_method :iframe, :remove_margins?, :viewport_width?

        def show; end

        private

        def iframe
          @iframe ||= sanitize(current_component.settings.iframe).html_safe
        end

        def sanitize(html)
          sanitizer = Rails::Html::SafeListSanitizer.new
          sanitizer.sanitize(html, tags: %w(iframe), attributes: ALLOWED_ATTRIBUTES)
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
