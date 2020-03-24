# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class ConfigController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig

        def show
          # enforce_permission_to :show, :config
          @form = form(ConfigForm).from_params(awesome_config)
        end

        def update
          # enforce_permission_to :update, :config

          @form = form(ConfigForm).from_params(params)

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
      end
    end
  end
end
