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

      def resource_path
        @resource_path ||= Decidim::ResourceLocatorPresenter.new(survey).path
      end

      def resource_url
        @resource_url ||= Decidim::ResourceLocatorPresenter.new(survey).url
      end

      def resource_title
        decidim_sanitize_translated(resource.follow_up_questionnaire.name)
      end

      private

      def survey
        resource.follow_up_questionnaire.questionnaire.questionnaire_for
      end
    end
  end
end
