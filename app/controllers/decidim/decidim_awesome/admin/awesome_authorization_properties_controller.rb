# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class AwesomeAuthorizationPropertiesController < DecidimAwesome::Admin::ApplicationController
        helper ConfigConstraintsHelpers

        before_action do
          enforce_permission_to :edit_config, :awesome_authorization_handler
        end

        def index
          @form = form(AwesomeAuthorizationPropertiesForm).from_params(current_properties)
        end

        def create
          @form = form(AwesomeAuthorizationPropertiesForm).from_params(params)

          UpdateAwesomeAuthorizationProperties.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("awesome_authorization_properties.create.success", scope: "decidim.decidim_awesome.admin")
              redirect_to decidim_admin_decidim_awesome.awesome_authorizations_path
            end

            on(:invalid) do |error|
              flash.now[:alert] = I18n.t("awesome_authorization_properties.create.error", error:, scope: "decidim.decidim_awesome.admin")
              render :index
            end
          end
        end

        private

        def current_properties
          value = AwesomeConfig.find_by(var: :awesome_authorization_handler, organization: current_organization)&.value
          return {} unless value.is_a?(Hash)

          value.slice("name", "explanation")
        end
      end
    end
  end
end
