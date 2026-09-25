# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class FollowUpQuestionnaireMessage < ApplicationRecord
      include Decidim::HasAttachments
      include Decidim::TranslatableAttributes

      self.table_name = "decidim_awesome_follow_up_questionnaire_messages"

      belongs_to :follow_up_questionnaire,
                 class_name: "Decidim::DecidimAwesome::FollowUpQuestionnaire",
                 inverse_of: :messages

      belongs_to :status,
                 class_name: "Decidim::DecidimAwesome::FollowUpQuestionnaireStatus",
                 inverse_of: :messages

      belongs_to :author, polymorphic: true

      validates :body, length: { maximum: 65_535 }, allow_nil: true

      scope :recent, -> { order(created_at: :desc) }

      delegate :name, :color, to: :status, prefix: true, allow_nil: true

      def organization
        questionnaire_for = follow_up_questionnaire.questionnaire.questionnaire_for
        return unless questionnaire_for.respond_to?(:component)

        questionnaire_for.component&.organization
      end

      def attachment_context
        :admin
      end

      def can_participate?(_user)
        true
      end

      def display_body
        body.presence || I18n.t(
          "decidim.decidim_awesome.admin.follow_up_questionnaire_messages.auto_status_change_body",
          status: translated_attribute(status.name)
        )
      end
    end
  end
end
