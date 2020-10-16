# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module IframeComponent
      class IframeController < DecidimAwesome::IframeComponent::ApplicationController
        helper_method :iframe

        def show; end

        private

        def iframe
          current_component.settings.iframe.html_safe
        end
      end
    end
  end
end
