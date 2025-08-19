# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class ForceAuthorizationsController < DecidimAwesome::Admin::ConfigController
        def create
          CreateAuthorizationGroup.call(current_organization, config_var) do
            on(:ok) do |key|
              flash[:notice] = I18n.t("config.create_force_authorization.success", key:, scope: "decidim.decidim_awesome.admin")
            end

            on(:invalid) do |message|
              flash[:alert] = I18n.t("config.create_force_authorization.error", error: message, scope: "decidim.decidim_awesome.admin")
            end
          end

          redirect_to decidim_admin_decidim_awesome.config_path(:verifications)
        end

        def destroy
          DestroyAuthorizationGroup.call(params[:id], current_organization, config_var) do
            on(:ok) do |key|
              flash[:notice] = I18n.t("config.destroy_force_authorization.success", key:, scope: "decidim.decidim_awesome.admin")
            end

            on(:invalid) do |message|
              flash[:alert] = I18n.t("config.destroy_force_authorization.error", error: message, scope: "decidim.decidim_awesome.admin")
            end
          end

          redirect_to decidim_admin_decidim_awesome.config_path(:verifications)
        end

        private

        # maybe in the future we want to restrict the admin as well
        def config_var
          :force_authorizations
        end
      end
    end
  end
end
