# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module OverviewComponent
      # This is the engine that runs on the admin interface of `DecidimAwesome::OverviewComponent`.
      class AdminEngine < ::Rails::Engine
        isolate_namespace Decidim::DecidimAwesome::OverviewComponent::Admin

        paths["db/migrate"] = nil
        paths["lib/tasks"] = nil

        routes do
          # Add admin engine routes here
          resources :components
          root to: "components#edit"
        end

        def load_seed
          nil
        end
      end
    end
  end
end
