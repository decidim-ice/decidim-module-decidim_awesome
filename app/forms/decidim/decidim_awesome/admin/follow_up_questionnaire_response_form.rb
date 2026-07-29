# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class FollowUpQuestionnaireResponseForm < Decidim::Form
        attribute :follow_up_questionnaire_id, Integer
        attribute :questionnaire_submission_id, Integer
        attribute :status_id, Integer
        attribute :body, String
        attribute :author_id, Integer

        validates :follow_up_questionnaire_id, :questionnaire_submission_id, :status_id, :author_id, presence: true, numericality: { only_integer: true }
        validate :status_belongs_to_questionnaire

        def to_params
          {
            follow_up_questionnaire_id: follow_up_questionnaire_id,
            questionnaire_submission_id: questionnaire_submission_id,
            status_id: status_id,
            body: body.to_s.strip.presence,
            author_id: author_id
         }
        end

        private

        def status_belongs_to_questionnaire
          return if status_id.blank? || follow_up_questionnaire_id.blank?

          status = context[:statuses_by_id]&.[](status_id)
          return if status && status.follow_up_questionnaire_id == follow_up_questionnaire_id

          errors.add(:status_id, :invalid)
        end
      end
    end
  end
end
