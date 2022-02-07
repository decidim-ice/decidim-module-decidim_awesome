# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module MapComponent
      class MapController < DecidimAwesome::BlankComponentController
        helper Decidim::DecidimAwesome::MapHelper
        helper_method :map_components, :api_ready?

        def show
          render :error unless maps_enabled?
        end

        private

        def maps_enabled?
          Decidim::Map.configured?
        end

        def api_ready?
          Decidim::Api::Schema.max_complexity >= 1300
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
