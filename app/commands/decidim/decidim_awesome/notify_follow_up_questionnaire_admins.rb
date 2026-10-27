# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class NotifyFollowUpQuestionnaireAdmins < Decidim::Command
      def initialize(questionnaire, session_token)
        @questionnaire = questionnaire
        @session_token = session_token
      end

      def call
        return broadcast(:invalid) unless notifiable?

        Decidim::EventsManager.publish(
          event: "decidim.events.decidim_awesome.follow_up_questionnaire_response_created",
          event_class: Decidim::DecidimAwesome::FollowUpQuestionnaireResponseCreatedEvent,
          resource: follow_up_questionnaire,
          affected_users: admins,
          extra: { force_email: true }
        )

        broadcast(:ok)
      end

      private

      attr_reader :questionnaire, :session_token

      def notifiable?
        follow_up_questionnaire.present? && admins.any? && responded?
      end

      def follow_up_questionnaire
        return @follow_up_questionnaire if defined?(@follow_up_questionnaire)

        @follow_up_questionnaire = FollowUpQuestionnaire.active.visible.find_by(decidim_questionnaire_id: questionnaire&.id)
      end

      def admins
        @admins ||= follow_up_questionnaire.notified_admins.to_a
      end

      # The event is also published when the responses are rolled back
      def responded?
        session_token.present? && Decidim::Forms::Response.exists?(questionnaire:, session_token:)
      end
    end
  end
end
