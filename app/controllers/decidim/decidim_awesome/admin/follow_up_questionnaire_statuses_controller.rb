# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class FollowUpQuestionnaireStatusesController < DecidimAwesome::Admin::ApplicationController
        before_action :follow_up_questionnaire
        before_action :status, only: [:update, :destroy]

        def index; end

        def new
          @form = form(FollowUpQuestionnaireStatusForm).instance
        end

        def create
          @form = form(FollowUpQuestionnaireStatusForm).from_params(params)

          CreateFollowUpQuestionnaireStatus.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("follow_up_questionnaire_statuses.create.success", scope: "decidim.decidim_awesome.admin")
              redirect_to decidim_admin_decidim_awesome.edit_follow_up_questionnaire_path(follow_up_questionnaire.decidim_questionnaire_id)
            end
            on(:invalid) do
              flash.now[:alert] = I18n.t("follow_up_questionnaire_statuses.create.error", scope: "decidim.decidim_awesome.admin")
              render action: :new, status: :unprocessable_content
            end
          end
        end

        def edit
          @form = form(FollowUpQuestionnaireStatusForm).from_model(status)
        end

        def update
          @form = form(FollowUpQuestionnaireStatusForm).from_params(params)

          UpdateFollowUpQuestionnaireStatus.call(@form, status) do
            on(:ok) do
              flash[:notice] = I18n.t("follow_up_questionnaire_statuses.update.success", scope: "decidim.decidim_awesome.admin")
              redirect_to decidim_admin_decidim_awesome.edit_follow_up_questionnaire_path(follow_up_questionnaire.decidim_questionnaire_id)
            end
            on(:invalid) do
              flash.now[:alert] = I18n.t("follow_up_questionnaire_statuses.update.error", scope: "decidim.decidim_awesome.admin")
              render action: :edit, status: :unprocessable_content
            end
          end
        end

        def destroy
          DestroyFollowUpQuestionnaireStatus.call(status, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("follow_up_questionnaire_statuses.destroy.success", scope: "decidim.decidim_awesome.admin")
              redirect_to decidim_admin_decidim_awesome.edit_follow_up_questionnaire_path(follow_up_questionnaire.decidim_questionnaire_id)
            end
          end
        end

        private

        def follow_up_questionnaire
          @follow_up_questionnaire ||= FollowUpQuestionnaire.find(params[:follow_up_questionnaire_id])
        end

        def status
          @status ||= follow_up_questionnaire.statuses.find(params[:id])
        end
      end
    end
  end
end
