# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module MapComponent
      class MapController < DecidimAwesome::MapComponent::ApplicationController
        helper Decidim::DecidimAwesome::MapHelper
        helper_method :map_components

        def show
          render :error unless maps_enabled?
        end

        private

        def maps_enabled?
          return Decidim::Map.configured? if defined?(Decidim::Map)

          # TODO: remove when 0.22 support is diched
          Decidim.geocoder.present?
        end

        def map_components
          @map_components ||= current_participatory_space.components.published.filter do |component|
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
