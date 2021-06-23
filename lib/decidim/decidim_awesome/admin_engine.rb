# frozen_string_literal: true

require "decidim/decidim_awesome/awesome_helpers"

module Decidim
  module DecidimAwesome
    # This is the engine that runs on the public interface of `DecidimAwesome`.
    class AdminEngine < ::Rails::Engine
      include AwesomeHelpers

      isolate_namespace Decidim::DecidimAwesome::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        # Add admin engine routes here
        resources :constraints
        resources :menu_hacks, except: [:show]
        resources :config, param: :var, only: [:show, :update]
        resources :scoped_styles, param: :var, only: [:create, :destroy]
        resources :scoped_admins, param: :var, only: [:create, :destroy]
        get :checks, to: "checks#index"
        root to: "config#show", var: :editors
      end

      initializer "decidim_admin_awesome.assets" do |app|
        app.config.assets.precompile += if version_prefix == "0.23"
                                          %w(legacy_decidim_admin_decidim_awesome_manifest.js decidim_admin_decidim_awesome_manifest.css)
                                        else
                                          %w(decidim_admin_decidim_awesome_manifest.js decidim_admin_decidim_awesome_manifest.css)
                                        end
      end

      initializer "decidim_decidim_awesome.admin_mount_routes" do
        Decidim::Core::Engine.routes do
          mount Decidim::DecidimAwesome::AdminEngine, at: "/admin/decidim_awesome", as: "decidim_admin_decidim_awesome"
        end
      end

      initializer "decidim_awesome.admin_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.item I18n.t("menu.decidim_awesome", scope: "decidim.admin", default: "Decidim Awesome"),
                    decidim_admin_decidim_awesome.config_path(:editors),
                    icon_name: "fire",
                    position: 7.5,
                    active: is_active_link?(decidim_admin_decidim_awesome.config_path(:editors), :inclusive)
        end
      end

      def load_seed
        nil
      end
    end
  end
end
