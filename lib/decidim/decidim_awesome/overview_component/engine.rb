# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module DecidimAwesome
    module OverviewComponent
      # This is the engine is used to create the overview component.
      class Engine < ::Rails::Engine
        isolate_namespace Decidim::DecidimAwesome::OverviewComponent

        routes do
          root to: "overview#show"
        end

        def load_seed
          nil
        end
      end
    end
  end
end
