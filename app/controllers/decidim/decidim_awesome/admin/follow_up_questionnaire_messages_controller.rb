# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class FollowUpQuestionnaireMessagesController < DecidimAwesome::Admin::ApplicationController
        include Decidim::Paginable

        skip_before_action :enforce_organization_admin!
        before_action :follow_up_questionnaire
        before_action :enforce_messages_permission!
        before_action :follow_up_questionnaire_message, only: [:show, :destroy]

        helper_method :current_participatory_space, :respondent_details

        def permission_class_chain
          [::Decidim::ParticipatoryProcesses::Permissions] + super
        end

        def index
          @questionnaire = @follow_up_questionnaire.questionnaire
          @participants = paginate(Decidim::Forms::QuestionnaireParticipants.new(@questionnaire).participants)
          @latest_messages_by_respondent = @follow_up_questionnaire.messages
                                                                   .group_by { |message| message.decidim_user_id || message.session_token }
                                                                   .transform_values { |messages| messages.max_by(&:created_at) }
        end

        def new; end

        def create; end

        def show; end

        def destroy; end

        private

        def follow_up_questionnaire
          @follow_up_questionnaire = Decidim::DecidimAwesome::FollowUpQuestionnaire.find_by!(decidim_questionnaire_id: params[:follow_up_questionnaire_id])
          Decidim::DecidimAwesome.create_default_statuses!(@follow_up_questionnaire) if @follow_up_questionnaire.statuses.empty?
          @follow_up_questionnaire
        end

        def current_participatory_space
          @current_participatory_space ||= FollowUpQuestionnairesFinder.new(current_organization)
                                                                       .component_for(@follow_up_questionnaire.questionnaire)
                                                                       &.participatory_space
        end

        def enforce_messages_permission!
          enforce_permission_to :read, :follow_up_questionnaire_messages, current_participatory_space: current_participatory_space
        end

        def respondent_details(participant)
          respondents_finder.respondent_for(decidim_user_id: participant.decidim_user_id, session_token: participant.session_token)
        end

        def respondents_finder
          @respondents_finder ||= FollowUpQuestionnaireRespondentsFinder.new(@follow_up_questionnaire)
        end
      end
    end
  end
end
