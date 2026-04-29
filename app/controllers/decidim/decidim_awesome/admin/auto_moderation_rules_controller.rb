# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class AutoModerationRulesController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig
        include ConfigConstraintsHelpers
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
          CreateAutoModerationRule.call(@form, current_organization) do
            on(:ok) do
              flash[:notice] = I18n.t("auto_moderation_rules.create.success", scope: "decidim.decidim_awesome.admin")
              redirect_to auto_moderation_rules_path
            end

            on(:invalid) do |message|
              flash[:alert] = I18n.t("auto_moderation_rules.create.error", error: message, scope: "decidim.decidim_awesome.admin")
              render :new
            end
          end
        end

        def edit
          @form = form(AutoModerationRulesForm).from_model(model_entry)
        end

        def update
          @form = form(AutoModerationRulesForm).from_params(params)
          rule_id = params[:id]
          UpdateAutoModerationRule.call(@form, rule_id, current_organization) do
            on(:ok) do
              flash[:notice] = I18n.t("auto_moderation_rules.update.success", scope: "decidim.decidim_awesome.admin")
              redirect_to auto_moderation_rules_path
            end

            on(:invalid) do |message|
              flash[:alert] = I18n.t("auto_moderation_rules.update.error", error: message, scope: "decidim.decidim_awesome.admin")
              render :edit
            end
          end
        end

        def destroy
          rule_id = params[:id]
          DestroyAutoModerationRule.call(rule_id, current_organization) do
            on(:ok) do
              flash[:notice] = I18n.t("auto_moderation_rules.destroy.success", scope: "decidim.decidim_awesome.admin")
              redirect_to auto_moderation_rules_path
            end

            on(:invalid) do |message|
              flash[:alert] = I18n.t("auto_moderation_rules.destroy.error", error: message, scope: "decidim.decidim_awesome.admin")
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

          rule_options =
            case entry["rule_options"]
            when Array
              entry["rule_options"].join(", ")
            else
              entry["rule_options"]
            end

          OpenStruct.new(
            description: entry["description"],
            rule_type: entry["rule_type"],
            enabled: entry["enabled"],
            rule_options: rule_options,
            targets: entry["targets"] || {}
          )
        end

        def rule_type_options
          Decidim::DecidimAwesome.moderation_rules_registry.manifests.map do |rule|
            name = I18n.t("decidim.decidim_awesome.admin.auto_moderation_rules.rule_type.#{rule.name}", default: rule.name.to_s.humanize)
            [name, rule.name]
          end
        end

        def targets
          entry = find_entry
          raise ActiveRecord::RecordNotFound unless entry

          @targets = entry["targets"] || {}
        end

        def constraints_for(key)
          awesome_config_instance.setting_for(key)&.constraints
        end

        def rules_manifests
          Decidim::DecidimAwesome.moderation_rules_registry.manifests
        end

        helper_method :entries, :rule_type_options, :targets, :constraints_for, :rules_manifests
      end
    end
  end
end
