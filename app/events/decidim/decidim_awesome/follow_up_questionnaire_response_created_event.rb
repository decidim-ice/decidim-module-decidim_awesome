# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # i18n-tasks-use t("decidim.events.decidim_awesome.follow_up_questionnaire_response_created.email_intro")
    # i18n-tasks-use t("decidim.events.decidim_awesome.follow_up_questionnaire_response_created.email_outro")
    # i18n-tasks-use t("decidim.events.decidim_awesome.follow_up_questionnaire_response_created.email_subject")
    # i18n-tasks-use t("decidim.events.decidim_awesome.follow_up_questionnaire_response_created.notification_title")
    class FollowUpQuestionnaireResponseCreatedEvent < Decidim::Events::SimpleEvent
      include Rails.application.routes.mounted_helpers

      def resource_title
        decidim_sanitize_translated(resource.name)
      end

      def resource_path
        decidim_admin_decidim_awesome.follow_up_questionnaire_messages_path(resource.decidim_questionnaire_id)
      end

      def resource_url
        decidim_admin_decidim_awesome.follow_up_questionnaire_messages_url(resource.decidim_questionnaire_id, host: resource.organization.host)
      end
    end
  end
end
