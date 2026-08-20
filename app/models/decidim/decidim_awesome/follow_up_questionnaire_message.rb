# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class FollowUpQuestionnaireMessage < ApplicationRecord
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
    end
  end
end
