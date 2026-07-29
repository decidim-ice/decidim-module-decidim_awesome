# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class FollowUpQuestionnaireStatus < ApplicationRecord
      belongs_to :follow_up_questionnaire,
                 class_name: "Decidim::DecidimAwesome::FollowUpQuestionnaire",
                 inverse_of: :statuses

      has_many :responses,
               class_name: "Decidim::DecidimAwesome::FollowUpQuestionnaireResponse",
               dependent: :restrict_with_exception,
               inverse_of: :status

      validates :name, presence: true, uniqueness: { scope: :follow_up_questionnaire_id }
      validates :color, presence: true
    end
  end
end
