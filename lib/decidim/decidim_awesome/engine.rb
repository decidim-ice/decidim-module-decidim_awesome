# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module DecidimAwesome
    # This is the engine that runs on the public interface of decidim_awesome.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::DecidimAwesome

      initializer "decidim_decidim_awesome.assets" do |app|
        app.config.assets.precompile += %w(decidim_decidim_awesome_manifest.js)
      end

      initializer "decidim_awesome.middleware" do |app|
        app.config.middleware.insert_after Decidim::CurrentOrganization, Decidim::DecidimAwesome::CurrentConfig
      end
    end
  end
end
