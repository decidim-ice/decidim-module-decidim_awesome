# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # This is the engine that runs on the public interface of `DecidimAwesome`.
    class ComponentAdminEngine < ::Rails::Engine
      isolate_namespace Decidim::DecidimAwesome::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :map
        resources :config, param: :var, only: [:show, :update]

        root to: "map#show"
      end

      def load_seed
        nil
      end
    end
  end
end
