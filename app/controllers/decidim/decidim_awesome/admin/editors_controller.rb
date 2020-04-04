# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      # Global configuration controller for editors
      class EditorsController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig
        include ConfigConstraintsHelpers

        layout "decidim/admin/decidim_awesome"

        helper_method :constraints_for, :translate_constraint_value

        def show
          @form = form(ConfigForm).from_params(unfiltered_awesome_config)
        end

        def update
          @form = form(ConfigForm).from_params(params)

          UpdateConfig.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("editors.update.success", scope: "decidim.decidim_awesome.admin")
              redirect_to decidim_admin_decidim_awesome.editors_path
            end

            on(:invalid) do |message|
              flash.now[:alert] = I18n.t("editors.update.error", error: message, scope: "decidim.decidim_awesome.admin")
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
