# frozen_string_literal: true

module Decidim
    module DecidimAwesome
        module Admin
            class AutoModerationTargetsController < DecidimAwesome::Admin::ApplicationController
                include NeedsAwesomeConfig
                helper ConfigConstraintsHelpers

                before_action do
                    enforce_permission_to :edit_config, :auto_moderation_rules
                end

                def new
                    @form = form(AutoModerationTargetForm).instance
                end

                def create
                    @form = form(AutoModerationTargetForm).from_params(params)
                    rule_id = params[:auto_moderation_rule_id]
                    CreateAutoModerationTarget.call(@form, rule_id, current_organization) do
                        on(:ok) do
                            flash[:notice] = I18n.t("auto_moderation_targets.create.success", scope: "decidim.decidim_awesome.admin")
                            redirect_to edit_auto_moderation_rule_path(rule_id)
                        end

                        on(:invalid) do |message|
                            flash.now[:alert] = I18n.t("auto_moderation_targets.create.error", error: message, scope: "decidim.decidim_awesome.admin")
                            render :new
                        end
                    end
                end

                def edit
                    @form = form(AutoModerationTargetForm).from_model(target_entry)
                end

                def update
                    @form = form(AutoModerationTargetForm).from_params(params)
                    target_id = params[:id]
                    rule_id = params[:auto_moderation_rule_id]
                    UpdateAutoModerationTarget.call(@form, rule_id, target_id, current_organization) do
                        on(:ok) do
                            flash[:notice] = I18n.t("auto_moderation_targets.update.success", scope: "decidim.decidim_awesome.admin")
                            redirect_to edit_auto_moderation_rule_path(rule_id)
                        end

                        on(:invalid) do |message|
                            flash.now[:alert] = I18n.t("auto_moderation_targets.update.error
                                ", error: message, scope: "decidim.decidim_awesome.admin")
                            render :edit
                        end
                    end
                end

                def destroy
                    target_id = params[:id]
                    rule_id = params[:auto_moderation_rule_id]
                    DestroyAutoModerationTarget.call(target_id, rule_id, current_organization) do
                        on(:ok) do
                            flash[:notice] = I18n.t("auto_moderation_targets.destroy.success", scope: "decidim.decidim_awesome.admin")
                            redirect_to edit_auto_moderation_rule_path(rule_id)
                        end

                        on(:invalid) do |message|
                            flash[:alert] = I18n.t("auto_moderation_targets.destroy.error", error: message, scope: "decidim.decidim_awesome.admin")
                            redirect_to edit_auto_moderation_rule_path(rule_id)
                        end
                    end
                end

                private

                def find_entry
                    awesome_config_instance.setting_for(:auto_moderation_rules).value[params[:auto_moderation_rule_id]]
                end

                def target_entry
                    entry = find_entry
                    raise ActiveRecord::RecordNotFound unless entry

                    target = entry["targets"]&.[](params[:id])
                    OpenStruct.new(
                        object_type: target["object_type"],
                        action_type: target["action_type"],
                        action_options: target["action_options"],
                        hits: target["hits"]
                    )
                end

                def object_type_options
                    [
                        [I18n.t("decidim.decidim_awesome.admin.auto_moderation_targets.form.object_type_options.proposal"), Decidim::Proposals::Proposal.model_name.element],
                        [I18n.t("decidim.decidim_awesome.admin.auto_moderation_targets.form.object_type_options.comment"), Decidim::Comments::Comment.model_name.element]
                    ]
                end

                def action_type_options
                    Decidim::DecidimAwesome.moderation_actions_registry.manifests.map do |manifest|
                        [I18n.t("decidim.decidim_awesome.admin.auto_moderation_targets.form.action_type_options.#{manifest.name}"), manifest.name.to_s]
                    end
                end

                helper_method :object_type_options, :action_type_options
            end
        end
    end
end