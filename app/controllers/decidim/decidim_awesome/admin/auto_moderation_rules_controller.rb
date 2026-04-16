# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class AutoModerationRulesController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig
        helper ConfigConstraintsHelpers

        before_action do
          enforce_permission_to :edit_config, :auto_moderation_rules
        end

        def index
          @rules = awesome_config_instance.setting_for(:auto_moderation_rules).value
        end

        def new
          @form = form(AutoModerationRulesForm).instance
        end

        def create
          @form = form(AutoModerationRulesForm).from_params(params)
          byebug
          CreateAutoModerationRule.call(@form, current_organization) do
            on(:ok) do
              #flash[:notice] = I18n.t("auto_moderation_rules.create.success", scope: "decidim.decidim_awesome.admin.config")
              flash[:notice] = "Success"
              redirect_to auto_moderation_rules_path
            end

            on(:invalid) do |message|
              #flash.now[:alert] = I18n.t("auto_moderation.create.error", error: message, scope: "decidim.decidim_awesome.admin.config")
              flash.now[:alert] = message
              render :new
            end
          end
        end

        def edit
          byebug
          @form = form(AutoModerationRulesForm).from_model(model_entry)
        end

        def destroy
          DestroyAutoModerationRule.call(entry_params, current_organization) do
            on(:ok) do
              flash[:notice] = I18n.t("auto_moderation.destroy.success", scope: "decidim.decidim_awesome.admin.config")
              redirect_to auto_moderation_rules_path
            end

            on(:invalid) do |message|
              flash.now[:alert] = I18n.t("auto_moderation.destroy.error", error: message, scope: "decidim.decidim_awesome.admin.config")
              redirect_to auto_moderation_rules_path
            end
          end
        end

        private

        def find_entry
          awesome_config_instance.setting_for(:auto_moderation_rules).value[params[:id]]
        end

        def entries
          awesome_config_instance.setting_for(:auto_moderation_rules) || []
        end

        def model_entry
          entry = find_entry
          raise ActiveRecord::RecordNotFound unless entry

          OpenStruct.new(
            description: entry["description"],
            enabled: entry["enabled"]
          )
        end


        helper_method :entries
      end
    end
  end
end
