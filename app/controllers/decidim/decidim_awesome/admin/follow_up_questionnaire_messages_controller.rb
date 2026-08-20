# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class FollowUpQuestionnaireMessagesController < DecidimAwesome::Admin::ApplicationController
        include Decidim::Paginable
        include Decidim::TranslatableAttributes
        include BreadcrumbHelpers

        skip_before_action :enforce_organization_admin!
        before_action :follow_up_questionnaire
        before_action :enforce_messages_permission!
        before_action :follow_up_questionnaire_message, only: [:show, :destroy]
        before_action :set_follow_up_questionnaire_breadcrumb, only: [:index, :new, :create]

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

        def new
          @messages = messages_for_respondent
          @statuses = @follow_up_questionnaire.statuses
          @form = form(FollowUpQuestionnaireMessageForm).instance(statuses_by_id: @statuses.index_by(&:id))
          @form.decidim_user_id = params[:decidim_user_id]
          @form.session_token = params[:session_token]
        end

        def create
          @statuses = @follow_up_questionnaire.statuses
          @form = form(FollowUpQuestionnaireMessageForm).from_params(
            params,
            follow_up_questionnaire_id: @follow_up_questionnaire.id,
            author_id: current_user.id,
            statuses_by_id: @statuses.index_by(&:id)
          )

          CreateFollowUpQuestionnaireMessage.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("follow_up_questionnaire_messages.create.success", scope: "decidim.decidim_awesome.admin")
              redirect_to follow_up_questionnaire_messages_path(@follow_up_questionnaire.decidim_questionnaire_id)
            end
            on(:invalid) do
              @messages = messages_for_respondent
              flash.now[:alert] = I18n.t("follow_up_questionnaire_messages.create.error", scope: "decidim.decidim_awesome.admin", error: @form.error_message)
              render action: :new, status: :unprocessable_content
            end
          end
        end

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

        def messages_for_respondent
          scope = @follow_up_questionnaire.messages
          scope = if params[:decidim_user_id].present?
                    scope.where(decidim_user_id: params[:decidim_user_id])
                  else
                    scope.where(session_token: params[:session_token])
                  end
          scope.recent
        end

        def respondents_finder
          @respondents_finder ||= FollowUpQuestionnaireRespondentsFinder.new(@follow_up_questionnaire)
        end

        def set_follow_up_questionnaire_breadcrumb
          add_breadcrumb_item translated_attribute(current_participatory_space.title),
                              Decidim::ResourceLocatorPresenter.new(current_participatory_space).edit
          add_breadcrumb_item translated_attribute(@follow_up_questionnaire.name), questionnaire_breadcrumb_url
          add_breadcrumb_item I18n.t("follow_up_questionnaire_messages.new.title", scope: "decidim.decidim_awesome.admin") unless action_name == "index"
        end

        def questionnaire_breadcrumb_url
          return if action_name == "index"

          follow_up_questionnaire_messages_path(@follow_up_questionnaire.decidim_questionnaire_id)
        end
      end
    end
  end
end
