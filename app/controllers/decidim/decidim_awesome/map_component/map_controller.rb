# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module MapComponent
      class MapController < DecidimAwesome::MapComponent::ApplicationController
        helper Decidim::DecidimAwesome::MapHelper
        helper_method :map_components

        def show
          render :error if Decidim.geocoder.blank?
        end

        private

        def map_components
          current_participatory_space.components.filter do |component|
            case component.manifest.name
            when :meetings
              true
            when :proposals
              component.settings.geocoding_enabled
            else
              false
            end
          end
        end
      end
    end
  end
end
