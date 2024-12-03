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
        resources :menus, only: [:show] do
          resources :hacks, except: [:show], controller: "menu_hacks"
        end
        resources :custom_redirects, except: [:show]
        resources :config, param: :var, only: [:show, :update]
        resources :scoped_styles, param: :var, only: [:create, :destroy]
        resources :proposal_custom_fields, param: :var, only: [:create, :destroy]
        resources :scoped_admins, param: :var, only: [:create, :destroy]
        get :admin_accountability, to: "admin_accountability#index", as: "admin_accountability"
        post :export_admin_accountability, to: "admin_accountability#export", as: "export_admin_accountability"
        get :users, to: "config#users"
        post :rename_scope_label, to: "config#rename_scope_label"
        resources :maintenance, only: [:show] do
          delete :destroy_private_data, on: :member
          get :checks, on: :collection, to: "checks#index"
        end
        resources :admin_authorizations, only: [:edit, :update, :destroy]
        post :migrate_images, to: "checks#migrate_images"
        root to: "config#show"
      end

      initializer "decidim_decidim_awesome.admin_mount_routes" do
        Decidim::Core::Engine.routes do
          mount Decidim::DecidimAwesome::AdminEngine, at: "/admin/decidim_awesome", as: "decidim_admin_decidim_awesome"
        end
      end

      initializer "decidim_awesome.admin_menus" do
        first_available = Decidim::DecidimAwesome::Menu.menus.detect { |_key, val| val.present? }&.first

        Decidim.menu :admin_menu do |menu|
          menu.add_item :awesome_menu,
                        I18n.t("menu.decidim_awesome", scope: "decidim.admin"),
                        if first_available
                          decidim_admin_decidim_awesome.config_path(first_available)
                        else
                          decidim_admin_decidim_awesome.checks_maintenance_index_path
                        end,
                        icon_name: "fire",
                        position: 7.5,
                        active: if first_available
                                  is_active_link?(decidim_admin_decidim_awesome.config_path(first_available), :inclusive)
                                else
                                  is_active_link?(decidim_admin_decidim_awesome.checks_maintenance_index_path)
                                end,
                        if: defined?(current_user) && current_user&.read_attribute("admin")
        end
        # submenus
        Decidim::DecidimAwesome::Menu.register_custom_fields_submenu!
        Decidim::DecidimAwesome::Menu.register_custom_styles_submenu!
        Decidim::DecidimAwesome::Menu.register_menu_hacks_submenu!
        Decidim::DecidimAwesome::Menu.register_maintenance_admin_menu!
        Decidim::DecidimAwesome::Menu.register_awesome_admin_menu!

        # user menu
        Decidim.menu :admin_user_menu do |menu|
          if DecidimAwesome.enabled? :admin_accountability
            menu.add_item :admin_accountability,
                          I18n.t("menu.admin_accountability", scope: "decidim.admin"),
                          decidim_admin_decidim_awesome.admin_accountability_path,
                          active: is_active_link?(decidim_admin_decidim_awesome.admin_accountability_path, :inclusive),
                          position: 7
          end
        end
      end

      def load_seed
        nil
      end
    end
  end
end
