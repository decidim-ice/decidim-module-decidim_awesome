# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      # Editing menu items
      class MenuHacksController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig
        helper ConfigConstraintsHelpers

        layout "decidim/admin/decidim_awesome"

        helper_method :current_menu, :current_menu_name

        before_action do
          enforce_permission_to :edit_config, :menu
        end

        def new
          @form = form(MenuForm).instance
        end

        def create
          @form = form(MenuForm).from_params(params)
          CreateMenuHack.call(@form, current_menu_name) do
            on(:ok) do
              flash[:notice] = I18n.t("menu_hacks.create.success", scope: "decidim.decidim_awesome.admin")
              redirect_to decidim_admin_decidim_awesome.menu_hacks_path
            end

            on(:invalid) do |message|
              flash.now[:alert] = I18n.t("menu_hacks.create.error", error: message, scope: "decidim.decidim_awesome.admin")
              render :new
            end
          end
        end

        def update
          @form = form(MenuForm).from_params(params)
          UpdateMenuHack.call(@form, current_menu_name) do
            on(:ok) do
              flash[:notice] = I18n.t("menu_hacks.update.success", scope: "decidim.decidim_awesome.admin")
              redirect_to decidim_admin_decidim_awesome.menu_hacks_path
            end

            on(:invalid) do |message|
              flash.now[:alert] = I18n.t("menu_hacks.update.error", error: message, scope: "decidim.decidim_awesome.admin")
              render :edit
            end
          end
        end

        def current_menu
          @current_menu ||= MenuHacker.new(current_menu_name, current_organization, self).items
        end

        def current_menu_name
          :menu
        end
      end
    end
  end
end
