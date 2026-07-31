# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class FollowUpQuestionnairesController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig

        before_action do
          enforce_permission_to :edit_config, :follow_up_questionnaires
        end

        def index
          @follow_up_questionnaires = Decidim::Forms::Questionnaire.order(created_at: :desc)
        end

        def new
          @form = form(FollowUpQuestionnaireForm).instance
        end

        def edit
          @follow_up_questionnaire = follow_up_questionnaire
          @form = form(FollowUpQuestionnaireForm).from_model(@follow_up_questionnaire)
        end

        def create
          @form = form(FollowUpQuestionnaireForm).from_params(params)
          @form.decidim_questionnaire_id ||= params[:id] || params[:decidim_questionnaire_id]

          CreateFollowUpQuestionnaire.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("follow_up_questionnaires.create.success", scope: "decidim.decidim_awesome.admin")
              redirect_to decidim_admin_decidim_awesome.follow_up_questionnaires_path
            end

            on(:invalid) do |error_message|
              error = error_message.presence || @form.errors.full_messages.join(", ")
              flash.now[:alert] = I18n.t("follow_up_questionnaires.create.error", scope: "decidim.decidim_awesome.admin", error: error)
              render :new
            end
          end
        end

        def update
          @follow_up_questionnaire = follow_up_questionnaire
          @form = form(FollowUpQuestionnaireForm).from_params(params)
          @form.decidim_questionnaire_id ||= params[:id] || params[:decidim_questionnaire_id]

          UpdateFollowUpQuestionnaire.call(@form, @follow_up_questionnaire) do
            on(:ok) do
              flash[:notice] = I18n.t("follow_up_questionnaires.update.success", scope: "decidim.decidim_awesome.admin")
              redirect_to decidim_admin_decidim_awesome.follow_up_questionnaires_path
            end

            on(:invalid) do |error_message|
              error = error_message.presence || @form.errors.full_messages.join(", ")
              flash.now[:alert] = I18n.t("follow_up_questionnaires.update.error", scope: "decidim.decidim_awesome.admin", error: error)
              render :edit
            end
          end
        end

        def destroy
          DestroyFollowUpQuestionnaire.call(follow_up_questionnaire) do
            on(:ok) do
              flash[:notice] = I18n.t("follow_up_questionnaires.destroy.success", scope: "decidim.decidim_awesome.admin")
            end

            on(:invalid) do |error_message|
              flash[:alert] = I18n.t("follow_up_questionnaires.destroy.error", scope: "decidim.decidim_awesome.admin", error: error_message)
            end
          end

          redirect_to decidim_admin_decidim_awesome.follow_up_questionnaires_path
        end

        private

        # The :id route param always refers to the Decidim::Forms::Questionnaire id
        # (see the index view), not the FollowUpQuestionnaire's own primary key.
        # A FollowUpQuestionnaire may not exist yet for a given questionnaire, in
        # which case a new (unpersisted) one is built so it can be configured for
        # the first time from the same edit/update flow.
        def follow_up_questionnaire
          @follow_up_questionnaire ||= Decidim::DecidimAwesome::FollowUpQuestionnaire.find_by(decidim_questionnaire_id: params[:id]) ||
                                       Decidim::DecidimAwesome::FollowUpQuestionnaire.new(decidim_questionnaire_id: params[:id])
        end
      end
    end
  end
end
