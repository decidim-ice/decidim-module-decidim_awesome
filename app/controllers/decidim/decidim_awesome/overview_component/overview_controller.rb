# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module OverviewComponent
      class OverviewController < DecidimAwesome::OverviewComponent::ApplicationController
        helper_method :components

        ALLOWED_COMPONENTS = %w(proposals).freeze

        def show; end

        private

        def components(manifest_name = ALLOWED_COMPONENTS)
          Decidim::Component.published.where(participatory_space: current_component.participatory_space, manifest_name: manifest_name)
        end
      end
    end
  end
end
