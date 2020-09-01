# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module DecidimAwesome
    # This is the engine that runs on the public interface of decidim_awesome.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::DecidimAwesome

      routes do
        post :editor_images, to: "editor_images#create"

        root to: "map#show"
      end

      initializer "decidim_decidim_awesome.assets" do |app|
        app.config.assets.precompile += %w(decidim_decidim_awesome_manifest.js decidim_decidim_awesome_manifest.css)
      end

      initializer "decidim_decidim_awesome.mount_routes" do
        Decidim::Core::Engine.routes do
          mount Decidim::DecidimAwesome::Engine, at: "/decidim_awesome", as: "decidim_decidim_awesome"
        end
      end

      initializer "decidim.decidim_awesome.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::DecidimAwesome::Engine.root}/app/views") # for partials
      end

      # Prepare a zone to create overrides
      # https://edgeguides.rubyonrails.org/engines.html#overriding-models-and-controllers
      config.to_prepare do
        Dir.glob("#{Engine.root}/app/overrides/**/*_override.rb").each do |override|
          require_dependency override
        end
      end
    end
  end
end
