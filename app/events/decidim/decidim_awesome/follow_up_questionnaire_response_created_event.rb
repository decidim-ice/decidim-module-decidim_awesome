# frozen_string_literal: true

module Decidim
  module DecidimAwesome
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
