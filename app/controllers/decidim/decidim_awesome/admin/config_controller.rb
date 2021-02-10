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

        # TODO: use commands, add flash messages
        def new_scoped_style
          styles = AwesomeConfig.find_or_initialize_by(var: :scoped_styles, organization: current_organization)
          styles.value = {} unless styles.value.is_a? Hash
          styles.value[rand(36**8).to_s(36)] = ""
          styles.save!
          redirect_to decidim_admin_decidim_awesome.config_path(:styles)
        end

        # TODO: use commands, add flash messages
        def destroy_scoped_style
          styles = AwesomeConfig.find_by(var: :scoped_styles, organization: current_organization)
          if styles&.value.is_a? Hash
            styles.value.except!(params[:key])
            styles.save!
            # remove constrains associated (a new config var is generated automatically, by removing it, it will trigger destroy on dependents)
            constraint = AwesomeConfig.find_by(var: "scoped_style_#{params[:key]}", organization: current_organization)
            constraint.destroy! if constraint.present?
          end
          redirect_to decidim_admin_decidim_awesome.config_path(:styles)
        end

        private

        def constraints_for(key)
          awesome_config_instance.setting_for(key)&.constraints
        end
      end
    end
  end
end
