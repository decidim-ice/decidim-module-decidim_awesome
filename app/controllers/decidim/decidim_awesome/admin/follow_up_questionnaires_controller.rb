# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class FollowUpQuestionnairesController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig
        include Decidim::Paginable
        helper FollowUpQuestionnairesHelper
        helper_method :available_questionnaires, :selected_questionnaire

        before_action do
          enforce_permission_to :edit_config, :follow_up_questionnaires
        end

        def index
          @follow_up_questionnaires = paginate(collection.ordered)
        end

        def new
          @form = form(FollowUpQuestionnaireForm).from_params({})
        end

        def create
          @form = form(FollowUpQuestionnaireForm).from_params(
            params, existing_questionnaire_ids: Decidim::DecidimAwesome::FollowUpQuestionnaire.pluck(:decidim_questionnaire_id)
          )
          CreateFollowUpQuestionnaire.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("follow_up_questionnaires.create.success", scope: "decidim.decidim_awesome.admin")
              redirect_to decidim_admin_decidim_awesome.follow_up_questionnaires_path
            end
            on(:invalid) do |error_message|
              error = error_message.presence || @form.errors.full_messages.join(", ")
              flash.now[:alert] = I18n.t("follow_up_questionnaires.create.error", scope: "decidim.decidim_awesome.admin", error:)
              render :new, status: :unprocessable_entity
            end
          end
        end

        def edit
          @follow_up_questionnaire = existing_follow_up_questionnaire!
          @form = form(FollowUpQuestionnaireForm).from_model(@follow_up_questionnaire)
        end

        def update
          @follow_up_questionnaire = existing_follow_up_questionnaire!
          existing_ids = Decidim::DecidimAwesome::FollowUpQuestionnaire.where.not(id: @follow_up_questionnaire.id).pluck(:decidim_questionnaire_id)
          @form = form(FollowUpQuestionnaireForm).from_params(params, existing_questionnaire_ids: existing_ids)
          # A disabled select is not submitted, keep the linked survey when it cannot be changed
          @form.decidim_questionnaire_id = @follow_up_questionnaire.decidim_questionnaire_id unless @follow_up_questionnaire.questionnaire_editable?

          UpdateFollowUpQuestionnaire.call(@form, @follow_up_questionnaire) do
            on(:ok) do
              flash[:notice] = I18n.t("follow_up_questionnaires.update.success", scope: "decidim.decidim_awesome.admin")
              redirect_to decidim_admin_decidim_awesome.follow_up_questionnaires_path
            end
            on(:invalid) do |error_message|
              error = error_message.presence || @form.errors.full_messages.join(", ")
              flash.now[:alert] = I18n.t("follow_up_questionnaires.update.error", scope: "decidim.decidim_awesome.admin", error:)
              render :edit, status: :unprocessable_entity
            end
          end
        end

        def destroy
          @follow_up_questionnaire = existing_follow_up_questionnaire!
          DestroyFollowUpQuestionnaire.call(@follow_up_questionnaire) do
            on(:ok) { flash[:notice] = I18n.t("follow_up_questionnaires.destroy.success", scope: "decidim.decidim_awesome.admin") }
            on(:invalid) { |error_message| flash[:alert] = I18n.t("follow_up_questionnaires.destroy.error", scope: "decidim.decidim_awesome.admin", error: error_message) }
          end
          redirect_to decidim_admin_decidim_awesome.follow_up_questionnaires_path
        end

        private

        def collection
          Decidim::DecidimAwesome::FollowUpQuestionnaire.where(organization: current_organization).visible
        end

        def finder(excluding: nil)
          FollowUpQuestionnairesFinder.new(current_organization, excluding:)
        end

        # Questionnaires of the organization that can be linked, including the one already linked when editing
        def available_questionnaires
          @available_questionnaires ||= finder(excluding: @follow_up_questionnaire&.id).query
        end

        def selected_questionnaire
          return if @form&.decidim_questionnaire_id.blank?

          @selected_questionnaire ||= available_questionnaires.find { |questionnaire| questionnaire.id == @form.decidim_questionnaire_id }
        end

        def existing_follow_up_questionnaire!
          follow_up_questionnaire = collection.find_by(decidim_questionnaire_id: params[:id])
          raise ActionController::RoutingError, "Not Found" unless follow_up_questionnaire

          Decidim::DecidimAwesome.create_default_statuses!(follow_up_questionnaire) if follow_up_questionnaire.statuses.empty?
          follow_up_questionnaire
        end
      end
    end
  end
end
