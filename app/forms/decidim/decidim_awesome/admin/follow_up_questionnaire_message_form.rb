# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class FollowUpQuestionnaireMessageForm < Decidim::Form
        include Decidim::AttachmentAttributes

        attribute :follow_up_questionnaire_id, Integer
        attribute :status_id, Integer
        attribute :body, String
        attribute :author_id, Integer
        attribute :decidim_user_id, Integer
        attribute :session_token, String

        attachments_attribute :attachments

        validates :follow_up_questionnaire_id, :status_id, :author_id, presence: true, numericality: { only_integer: true }
        validates :body, presence: true
        validate :status_belongs_to_questionnaire
        validate :respondent_present

        def to_params
          {
            follow_up_questionnaire_id: follow_up_questionnaire_id,
            status_id: status_id,
            body: body.to_s.strip.presence,
            author_id: author_id,
            decidim_user_id: decidim_user_id,
            session_token: session_token
          }
        end

        def error_message
          errors.full_messages.join(", ")
        end

        private

        def status_belongs_to_questionnaire
          return if status_id.blank? || follow_up_questionnaire_id.blank?

          status = context[:statuses_by_id]&.[](status_id)
          return if status && status.follow_up_questionnaire_id == follow_up_questionnaire_id

          errors.add(:status_id, :invalid)
        end

        def respondent_present
          errors.add(:base, :respondent_missing) if decidim_user_id.blank? && session_token.blank?
        end
      end
    end
  end
end
