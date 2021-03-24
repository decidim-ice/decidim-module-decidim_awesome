# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module DecidimAwesome
    module CallToAwesome
      # This is the engine is used to create the CallToAwesome component.
      class Engine < ::Rails::Engine
        isolate_namespace Decidim::DecidimAwesome::CallToAwesome

        routes do
          root to: "components#index"
        end

        def load_seed
          nil
        end

        initializer "decidim_awesome.call_to_awesome.add_cells_view_paths" do
          Cell::ViewModel.view_paths << File.expand_path("#{Decidim::DecidimAwesome::CallToAwesome::Engine.root}/app/cells")
        end
      end
    end
  end
end
