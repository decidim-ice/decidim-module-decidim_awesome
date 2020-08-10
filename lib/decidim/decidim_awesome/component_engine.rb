# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module DecidimAwesome
    # This is the engine that runs on the public interface of decidim_awesome.
    class ComponentEngine < ::Rails::Engine
      isolate_namespace Decidim::DecidimAwesome

      routes do
        resource :map

        root to: "map#show"
      end


      initializer "decidim.decidim_awesome.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::DecidimAwesome::Engine.root}/app/views") # for partials
      end
    end
  end
end
