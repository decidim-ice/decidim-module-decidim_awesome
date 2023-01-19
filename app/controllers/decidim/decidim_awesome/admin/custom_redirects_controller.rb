# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      # Editing menu items
      class CustomRedirectsController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig
        include ConfigConstraintsHelpers

        layout "decidim/admin/decidim_awesome"

        before_action do
          enforce_permission_to :edit_config, :menu
        end

        helper ConfigConstraintsHelpers
        helper_method :current_config

        def index; end

        def new
          @form = form(CustomRedirectForm).instance
        end

        def create
          @form = form(CustomRedirectForm).from_params(params)
          CreateCustomRedirect.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("custom_redirects.create.success", scope: "decidim.decidim_awesome.admin")
              redirect_to decidim_admin_decidim_awesome.custom_redirects_path
            end

            on(:invalid) do |message|
              flash.now[:alert] = I18n.t("custom_redirects.create.error", error: message, scope: "decidim.decidim_awesome.admin")
              render :new
            end
          end
        end

        def edit
          @form = form(CustomRedirectForm).from_model(redirect_item)
        end

        def update
          @form = form(CustomRedirectForm).from_params(params)
          UpdateCustomRedirect.call(@form, redirect_item) do
            on(:ok) do
              flash[:notice] = I18n.t("custom_redirects.update.success", scope: "decidim.decidim_awesome.admin")
              redirect_to decidim_admin_decidim_awesome.custom_redirects_path
            end

            on(:invalid) do |message|
              flash.now[:alert] = I18n.t("custom_redirects.update.error", error: message, scope: "decidim.decidim_awesome.admin")
              render :new
            end
          end
        end

        def destroy
          DestroyCustomRedirect.call(redirect_item, current_organization) do
            on(:ok) do
              flash[:notice] = I18n.t("custom_redirects.destroy.success", scope: "decidim.decidim_awesome.admin")
            end
            on(:invalid) do |error|
              flash[:alert] = I18n.t("custom_redirects.destroy.error", scope: "decidim.decidim_awesome.admin", error: error)
            end
          end
          redirect_to decidim_admin_decidim_awesome.custom_redirects_path
        end

        private

        def redirect_item
          origin, item = current_config.find { |origin, _| md5(origin) == params[:id] }
          raise ActiveRecord::RecordNotFound unless item

          # rubocop:disable Style/OpenStructUse
          OpenStruct.new(
            origin: origin,
            destination: item["destination"],
            active: item["active"]
          )
          # rubocop:enable Style/OpenStructUse
        end

        def current_config
          @current_config ||= (AwesomeConfig.find_by(var: :custom_redirects, organization: current_organization)&.value || {})
        end
      end
    end
  end
end
