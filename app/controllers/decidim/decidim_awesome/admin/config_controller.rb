# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      # Global configuration controller
      class ConfigController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig
        include ConfigConstraintsHelpers
        helper ConfigConstraintsHelpers

        layout "decidim/admin/decidim_awesome"

        helper_method :constraints_for, :find_menu

        def show
          @form = form(ConfigForm).from_params(organization_awesome_config)
        end

        def update
          @form = form(ConfigForm).from_params(params[:config])
          UpdateConfig.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("config.update.success", scope: "decidim.decidim_awesome.admin")
              redirect_to decidim_admin_decidim_awesome.config_path
            end

            on(:invalid) do |message|
              flash.now[:alert] = I18n.t("config.update.error", error: message, scope: "decidim.decidim_awesome.admin")
              render :show
            end
          end
        end

        def new_scoped_style
          CreateScopedStyle.call(current_organization) do
            on(:ok) do |key|
              flash[:notice] = I18n.t("config.create_scoped_style.success", key: key, scope: "decidim.decidim_awesome.admin")
            end

            on(:invalid) do |message|
              flash[:alert] = I18n.t("config.create_scoped_style.error", error: message, scope: "decidim.decidim_awesome.admin")
            end
          end

          redirect_to decidim_admin_decidim_awesome.config_path(:styles)
        end

        def destroy_scoped_style
          DestroyScopedStyle.call(params[:key], current_organization) do
            on(:ok) do |key|
              flash[:notice] = I18n.t("config.destroy_scoped_style.success", key: key, scope: "decidim.decidim_awesome.admin")
            end

            on(:invalid) do |message|
              flash[:alert] = I18n.t("config.destroy_scoped_style.error", error: message, scope: "decidim.decidim_awesome.admin")
            end
          end

          redirect_to decidim_admin_decidim_awesome.config_path(:styles)
        end

        private

        def constraints_for(key)
          awesome_config_instance.setting_for(key)&.constraints
        end

        def find_menu(name)
          menu = Decidim::Menu.new(name)
          menu.build_for(self)
          menu.items
        end
      end
    end
  end
end
