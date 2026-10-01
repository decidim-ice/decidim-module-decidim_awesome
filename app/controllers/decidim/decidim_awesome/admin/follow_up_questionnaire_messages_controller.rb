# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      # Space admins manage the messages of their own spaces, so this controller does not inherit
      # the organization admin check of DecidimAwesome::Admin::ApplicationController
      class FollowUpQuestionnaireMessagesController < Decidim::Admin::ApplicationController
        include Decidim::Paginable
        include Decidim::TranslatableAttributes
        include BreadcrumbHelpers

        helper Decidim::ResourceHelper

        before_action :follow_up_questionnaire
        before_action :enforce_messages_permission!
        before_action :participant, only: [:new, :create]
        before_action :set_follow_up_questionnaire_breadcrumb, only: [:index, :new, :create]

        helper_method :current_participatory_space, :respondent_details, :preview_response_path, :reply_to_email

        layout "decidim/decidim_awesome/admin/application"

        # Like the admin controllers of each space type, only the permissions of the current space are used.
        # Adding every space type makes the ones of other spaces deny what the current one allowed.
        def permission_class_chain
          space_permissions = current_participatory_space&.manifest&.permissions_class
          [::Decidim::DecidimAwesome::Admin::Permissions, space_permissions].compact + super
        end

        # i18n-tasks-use t("decidim.decidim_awesome.admin.follow_up_questionnaire_messages.index.last_action_answered")
        # i18n-tasks-use t("decidim.decidim_awesome.admin.follow_up_questionnaire_messages.index.last_action_labeled")
        def index
          @questionnaire = @follow_up_questionnaire.questionnaire
          @participants = paginate(Decidim::Forms::QuestionnaireParticipants.new(@questionnaire).participants)
          messages_by_respondent = @follow_up_questionnaire.messages.group_by { |message| message.decidim_user_id || message.session_token }
          @latest_messages_by_respondent = messages_by_respondent.transform_values { |messages| messages.max_by(&:created_at) }
          @messages_count_by_respondent = messages_by_respondent.transform_values { |messages| messages.count { |message| message.body.present? } }
        end

        def new
          @statuses = @follow_up_questionnaire.statuses
          assign_reply_view_variables
          @form = form(FollowUpQuestionnaireMessageForm).instance(
            statuses_by_id: @statuses.index_by(&:id),
            current_participatory_space: current_participatory_space
          )
          @form.follow_up_questionnaire_id = @follow_up_questionnaire.id
          @form.author_id = current_user.id
          assign_recipient
          @form.status_id = @messages.first&.status_id
        end

        def create
          @statuses = @follow_up_questionnaire.statuses
          @form = form(FollowUpQuestionnaireMessageForm).from_params(
            params,
            statuses_by_id: @statuses.index_by(&:id),
            current_participatory_space: current_participatory_space
          )
          @form.follow_up_questionnaire_id = @follow_up_questionnaire.id
          assign_recipient

          CreateFollowUpQuestionnaireMessage.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("follow_up_questionnaire_messages.create.success", scope: "decidim.decidim_awesome.admin")
              redirect_to follow_up_questionnaire_messages_path(follow_up_questionnaire.decidim_questionnaire_id)
            end
            on(:invalid) do
              assign_reply_view_variables
              flash.now[:alert] = I18n.t("follow_up_questionnaire_messages.create.error", scope: "decidim.decidim_awesome.admin", error: @form.error_message)
              render action: :new, status: :unprocessable_content
            end
          end
        end

        private

        def follow_up_questionnaire
          @follow_up_questionnaire = Decidim::DecidimAwesome::FollowUpQuestionnaire.where(organization: current_organization).visible
                                                                                   .find_by(decidim_questionnaire_id: params[:follow_up_questionnaire_id])
          raise ActionController::RoutingError, "Not Found" unless @follow_up_questionnaire

          @follow_up_questionnaire
        end

        def current_participatory_space
          @current_participatory_space ||= current_component&.participatory_space
        end

        def current_component
          return unless @follow_up_questionnaire

          @current_component ||= @follow_up_questionnaire.component
        end

        def preview_response_path(participant)
          survey = @follow_up_questionnaire.questionnaire.questionnaire_for
          return unless defined?(Decidim::Surveys::Survey) && survey.is_a?(Decidim::Surveys::Survey)

          Decidim::EngineRouter.admin_proxy(current_component).survey_response_path(survey, id: participant.session_token)
        end

        def reply_to_email
          @follow_up_questionnaire.reply_to.presence
        end

        def enforce_messages_permission!
          enforce_permission_to :read, :follow_up_questionnaire_messages, current_participatory_space: current_participatory_space
        end

        def respondent_details(participant)
          respondents_finder.respondent_for(decidim_user_id: participant.decidim_user_id, session_token: participant.session_token)
        end

        # The response of the recipient to the questionnaire, like Decidim::Forms::QuestionnaireParticipants#participant.
        # The ids received are only used to find it, so nobody who did not respond can be messaged.
        def participant
          @participant ||= begin
            participants = Decidim::Forms::QuestionnaireParticipants.new(@follow_up_questionnaire.questionnaire)
            response = if recipient_params[:decidim_user_id].present?
                         participants.query.find_by(decidim_user_id: recipient_params[:decidim_user_id])
                       elsif recipient_params[:session_token].present?
                         participants.participant(recipient_params[:session_token])
                       end
            response || raise(ActionController::RoutingError, "Not Found")
          end
        end

        # In create the recipient comes in the form hidden fields
        def recipient_params
          action_name == "create" ? params.fetch(:follow_up_questionnaire_message, {}) : params
        end

        def assign_recipient
          @form.decidim_user_id = participant.decidim_user_id
          @form.session_token = participant.session_token
        end

        def messages_for_respondent
          scope = @follow_up_questionnaire.messages
          scope = if participant.decidim_user_id.present?
                    scope.where(decidim_user_id: participant.decidim_user_id)
                  else
                    scope.where(session_token: participant.session_token)
                  end
          scope.recent
        end

        def respondents_finder
          @respondents_finder ||= FollowUpQuestionnaireRespondentsFinder.new(@follow_up_questionnaire)
        end

        def assign_reply_view_variables
          @messages = messages_for_respondent
          @respondent = respondent_details(participant)
          @submitted_at = original_submission_at
        end

        def original_submission_at
          scope = Decidim::Forms::Response.where(questionnaire: @follow_up_questionnaire.questionnaire)
          scope = if participant.decidim_user_id.present?
                    scope.where(decidim_user_id: participant.decidim_user_id)
                  else
                    scope.where(session_token: participant.session_token)
                  end
          scope.minimum(:created_at)
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
