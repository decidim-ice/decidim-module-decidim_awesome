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

        helper_method :constraints_for

        def show
          @form = form(ConfigForm).from_params(organization_awesome_config)
        end

        def update
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

        private

        def constraints_for(key)
          awesome_config_instance.setting_for(key)&.constraints
        end
      end
    end
  end
end
