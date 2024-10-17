# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      # Global configuration controller
      class ScopedStylesController < DecidimAwesome::Admin::ConfigController
        def create
          CreateScopedStyle.call(current_organization, config_var) do
            on(:ok) do |key|
              flash[:notice] = I18n.t("config.create_scoped_style.success", key:, scope: "decidim.decidim_awesome.admin")
            end

            on(:invalid) do |message|
              flash[:alert] = I18n.t("config.create_scoped_style.error", error: message, scope: "decidim.decidim_awesome.admin")
            end
          end

          redirect_to decidim_admin_decidim_awesome.config_path(config_var)
        end

        def destroy
          DestroyScopedStyle.call(params[:key], current_organization, config_var) do
            on(:ok) do |key|
              flash[:notice] = I18n.t("config.destroy_scoped_style.success", key:, scope: "decidim.decidim_awesome.admin")
            end

            on(:invalid) do |message|
              flash[:alert] = I18n.t("config.destroy_scoped_style.error", error: message, scope: "decidim.decidim_awesome.admin")
            end
          end

          redirect_to decidim_admin_decidim_awesome.config_path(config_var)
        end

        private

        def config_var
          return :scoped_admin_styles if params[:admin] == "true"

          :scoped_styles
        end
      end
    end
  end
end
