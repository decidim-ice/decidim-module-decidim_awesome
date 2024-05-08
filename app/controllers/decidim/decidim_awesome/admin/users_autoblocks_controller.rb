# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      # Autoblock users admin controller
      class UsersAutoblocksController < DecidimAwesome::Admin::ConfigController
        include ConfigConstraintsHelpers

        helper_method :types_options, :current_rules

        layout "decidim/decidim_awesome/admin/application"

        def index
          @config_form = form(UsersAutoblocksConfigForm).from_model(current_config)
        end

        def new
          @form = form(UsersAutoblocksForm).instance
        end

        def edit
          @form = form(UsersAutoblocksForm).from_model(users_autoblock_rule)
        end

        def create
          @form = form(UsersAutoblocksForm).from_params(params)

          CreateUsersAutoblockRule.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("success", scope: "decidim.decidim_awesome.admin.users_autoblocks.create")
              redirect_to decidim_admin_decidim_awesome.users_autoblocks_path
            end

            on(:invalid) do |message|
              flash.now[:alert] = I18n.t("error", error: message, scope: "decidim.decidim_awesome.admin.users_autoblocks.create")
              render :new
            end
          end
        end

        def update
          @form = form(UsersAutoblocksForm).from_params(params)
          UpdateUsersAutoblockRule.call(@form, users_autoblock_rule) do
            on(:ok) do
              flash[:notice] = I18n.t("success", scope: "decidim.decidim_awesome.admin.users_autoblocks.update")
              redirect_to decidim_admin_decidim_awesome.users_autoblocks_path
            end

            on(:invalid) do |message|
              flash.now[:alert] = I18n.t("error", error: message, scope: "decidim.decidim_awesome.admin.users_autoblocks.update")
              render :new
            end
          end
        end

        def destroy
          DestroyUsersAutoblockRule.call(users_autoblock_rule, current_organization) do
            on(:ok) do
              flash[:notice] = I18n.t("success", scope: "decidim.decidim_awesome.admin.users_autoblocks.destroy")
            end

            on(:invalid) do |message|
              flash[:alert] = I18n.t("error", error: message, scope: "decidim.decidim_awesome.admin.users_autoblocks.destroy")
            end
          end

          redirect_to decidim_admin_decidim_awesome.users_autoblocks_path
        end

        def detect_and_run
          @config_form = form(UsersAutoblocksConfigForm).from_params(params)

          AutoblockUsers.call(@config_form) do
            on(:ok) do
              flash[:notice] = I18n.t("success", scope: "decidim.decidim_awesome.admin.users_autoblocks.detect_and_run")
              redirect_to decidim_admin_decidim_awesome.users_autoblocks_path
            end

            on(:invalid) do |message|
              flash.now[:alert] = I18n.t("error", error: message, scope: "decidim.decidim_awesome.admin.users_autoblocks.detect_and_run")
              render :index
            end
          end
        end

        private

        def types_options
          UsersAutoblocksForm::USERS_AUTOBLOCKS_TYPES.keys.index_by { |key| I18n.t(key, scope: "decidim.decidim_awesome.admin.users_autoblocks.form.types") }
        end

        def current_rules
          @current_rules ||= (AwesomeConfig.find_by(var: :users_autoblocks, organization: current_organization)&.value || [])
        end

        def current_config
          @current_config ||= OpenStruct.new(AwesomeConfig.find_by(var: :users_autoblocks_config, organization: current_organization)&.value || {})
        end

        def users_autoblock_rule
          rule = current_rules.find { |r| md5(r.to_json) == params[:id] }
          raise ActiveRecord::RecordNotFound if rule.blank?

          OpenStruct.new(rule)
        end
      end
    end
  end
end
