# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      # Global configuration controller
      class ScopedAdminsController < DecidimAwesome::Admin::ConfigController
        def create
          CreateScopedAdmin.call(current_organization) do
            on(:ok) do |key|
              flash[:notice] = I18n.t("config.create_scoped_admin.success", key:, scope: "decidim.decidim_awesome.admin")
            end

            on(:invalid) do |message|
              flash[:alert] = I18n.t("config.create_scoped_admin.error", error: message, scope: "decidim.decidim_awesome.admin")
            end
          end

          redirect_to decidim_admin_decidim_awesome.config_path(:admins)
        end

        def destroy
          DestroyScopedAdmin.call(params[:key], current_organization) do
            on(:ok) do |key|
              flash[:notice] = I18n.t("config.destroy_scoped_admin.success", key:, scope: "decidim.decidim_awesome.admin")
            end

            on(:invalid) do |message|
              flash[:alert] = I18n.t("config.destroy_scoped_admin.error", error: message, scope: "decidim.decidim_awesome.admin")
            end
          end

          redirect_to decidim_admin_decidim_awesome.config_path(:admins)
        end
      end
    end
  end
end
