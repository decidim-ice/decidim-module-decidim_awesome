# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class FollowUpQuestionnaireMessageStatusChangedEvent < Decidim::Events::BaseEvent
      include Decidim::Events::NotificationEvent

      def notification_title
        I18n.t(
          "decidim.events.decidim_awesome.follow_up_questionnaire_message_status_changed.notification_title",
          questionnaire: decidim_sanitize_translated(resource.follow_up_questionnaire.name),
          status: decidim_sanitize_translated(resource.status.name)
        ).html_safe
      end
    end
  end
end
