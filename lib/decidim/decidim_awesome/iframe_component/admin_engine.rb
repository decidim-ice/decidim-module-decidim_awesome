# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module DecidimAwesome
    module IframeComponent
      # This is the engine is used to create the component Map.
      class AdminEngine < ::Rails::Engine
        isolate_namespace Decidim::DecidimAwesome::IframeComponent

        routes do
          root to: "iframe#settings"
        end

        def load_seed
          nil
        end
      end
    end
  end
end
