# frozen_string_literal: true

require "decidim/decidim_awesome/middleware/current_config"

module Decidim
  module DecidimAwesome
    # This is the engine that runs on the public interface of `DecidimAwesome`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::DecidimAwesome::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        # Add admin engine routes here
        get :config, to: "config#show"
        post :config, to: "config#update"
        post :editor_images, to: "editor_images#create"
        root to: "config#show"
      end

      initializer "decidim_admin_awesome.assets" do |app|
        app.config.assets.precompile += %w(decidim_admin_decidim_awesome_manifest.js)
      end

      initializer "decidim_admin_awesome.middleware" do |app|
        app.config.middleware.insert_after Decidim::CurrentOrganization, Decidim::DecidimAwesome::CurrentConfig
      end

      initializer "decidim_decidim_awesome.admin_mount_routes" do
        Decidim::Core::Engine.routes do
          mount Decidim::DecidimAwesome::AdminEngine, at: "/admin/decidim_awesome", as: "decidim_admin_decidim_awesome"
        end
      end

      initializer "decidim_awesome.admin_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.item I18n.t("menu.decidim_awesome", scope: "decidim.admin"),
                    decidim_admin_decidim_awesome.config_path,
                    icon_name: "fire",
                    position: 7.5,
                    active: is_active_link?(decidim_admin_decidim_awesome.config_path, :inclusive)
        end
      end

      def load_seed
        nil
      end
    end
  end
end
