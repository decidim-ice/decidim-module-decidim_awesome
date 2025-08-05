# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class AuthorizationGroupsController < DecidimAwesome::Admin::ConfigController
        def create
          CreateAuthorizationGroup.call(current_organization, config_var) do
            on(:ok) do |key|
              flash[:notice] = I18n.t("config.create_authorization_group.success", key:, scope: "decidim.decidim_awesome.admin")
            end

            on(:invalid) do |message|
              flash[:alert] = I18n.t("config.create_authorization_group.error", error: message, scope: "decidim.decidim_awesome.admin")
            end
          end

          redirect_to decidim_admin_decidim_awesome.config_path(:verifications)
        end

        def destroy
          DestroyAuthorizationGroup.call(params[:id], current_organization, config_var) do
            on(:ok) do |key|
              flash[:notice] = I18n.t("config.destroy_authorization_group.success", key:, scope: "decidim.decidim_awesome.admin")
            end

            on(:invalid) do |message|
              flash[:alert] = I18n.t("config.destroy_authorization_group.error", error: message, scope: "decidim.decidim_awesome.admin")
            end
          end

          redirect_to decidim_admin_decidim_awesome.config_path(:verifications)
        end

        private

        def config_var
          return :admin_authorization_groups if params[:admin_panel] == "true"

          :authorization_groups
        end
      end
    end
  end
end
