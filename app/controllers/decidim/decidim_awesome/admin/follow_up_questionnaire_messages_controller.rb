# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class FollowUpQuestionnaireMessagesController < DecidimAwesome::Admin::ApplicationController
        skip_before_action :enforce_organization_admin!
        before_action :follow_up_questionnaire
        before_action :enforce_messages_permission!
        before_action :follow_up_questionnaire_message, only: [:show, :edit, :update, :destroy]

        def index
          @questionnaire = @follow_up_questionnaire.questionnaire
          @participants = Decidim::Forms::QuestionnaireParticipants.new(@questionnaire).participants
          @latest_messages_by_respondent = @follow_up_questionnaire.messages
                                                                   .group_by { |message| message.decidim_user_id || message.session_token }
                                                                   .transform_values { |messages| messages.max_by(&:created_at) }
          @respondent_names = responses_for_question(@follow_up_questionnaire.responder_name_field)
          @respondent_emails = responses_for_question(@follow_up_questionnaire.responder_email_field)
        end

        def edit; end

        def show; end

        def update; end

        def destroy; end

        private

        def follow_up_questionnaire
          @follow_up_questionnaire = Decidim::DecidimAwesome::FollowUpQuestionnaire.find_by!(decidim_questionnaire_id: params[:follow_up_questionnaire_id])
        end

        def current_participatory_space
          @current_participatory_space ||= FollowUpQuestionnairesFinder.new(current_organization)
                                                                       .component_for(@follow_up_questionnaire.questionnaire)
                                                                       &.participatory_space
        end

        def enforce_messages_permission!
          enforce_permission_to :read, :follow_up_questionnaire_messages, current_participatory_space: current_participatory_space
        end

        def responses_for_question(question_id)
          return {} if question_id.blank?

          Decidim::Forms::Response.where(questionnaire: @questionnaire, decidim_question_id: question_id)
                                  .index_by { |response| response.decidim_user_id || response.session_token }
        end
      end
    end
  end
end
