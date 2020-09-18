# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module DecidimAwesome
    module MapComponent
      # This is the engine is used to create the component Map.
      class Engine < ::Rails::Engine
        isolate_namespace Decidim::DecidimAwesome::MapComponent

        routes do
          root to: "map#show"
        end

        def load_seed
          nil
        end
      end
    end
  end
end
