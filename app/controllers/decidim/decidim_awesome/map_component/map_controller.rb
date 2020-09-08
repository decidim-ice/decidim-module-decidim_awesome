# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module MapComponent
      class MapController < DecidimAwesome::MapComponent::ApplicationController
        helper Decidim::DecidimAwesome::MapHelper
        helper_method :map_components

        private

        # TODO: filter geolocated only here
        def map_components
          current_participatory_space.components.filter do |component|
            [:proposals, :meetings].include? component.manifest.name
          end
        end
      end
    end
  end
end
