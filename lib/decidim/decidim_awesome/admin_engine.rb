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
        resources :custom_redirects, except: [:show]
        resources :config, param: :var, only: [:show, :update]
        resources :scoped_styles, param: :var, only: [:create, :destroy]
        resources :proposal_custom_fields, param: :var, only: [:create, :destroy]
        resources :scoped_admins, param: :var, only: [:create, :destroy]
        get :users, to: "config#users"
        post :rename_scope_label, to: "config#rename_scope_label"
        get :checks, to: "checks#index"
        post :migrate_images, to: "checks#migrate_images"
        root to: "config#show"
      end

      initializer "decidim_decidim_awesome.admin_mount_routes" do
        Decidim::Core::Engine.routes do
          mount Decidim::DecidimAwesome::AdminEngine, at: "/admin/decidim_awesome", as: "decidim_admin_decidim_awesome"
        end
      end

      initializer "decidim_awesome.admin_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.add_item :awesome_menu,
                        I18n.t("menu.decidim_awesome", scope: "decidim.admin", default: "Decidim Awesome"),
                        decidim_admin_decidim_awesome.config_path(:editors),
                        icon_name: "fire",
                        position: 7.5,
                        active: is_active_link?(decidim_admin_decidim_awesome.config_path(:editors), :inclusive),
                        if: defined?(current_user) && current_user&.read_attribute("admin")
        end
      end

      def load_seed
        nil
      end
    end
  end
end
