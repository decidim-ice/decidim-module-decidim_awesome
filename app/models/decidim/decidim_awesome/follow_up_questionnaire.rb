# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class FollowUpQuestionnaire < ApplicationRecord
      include Decidim::TranslatableAttributes
      include Decidim::TranslatableResource

      translatable_fields :name

      self.table_name = "decidim_awesome_follow_up_questionnaires"

      belongs_to :questionnaire,
                 class_name: "Decidim::Forms::Questionnaire",
                 foreign_key: :decidim_questionnaire_id

      has_many :statuses,
               class_name: "Decidim::DecidimAwesome::FollowUpQuestionnaireStatus",
               dependent: :destroy,
               inverse_of: :follow_up_questionnaire

      has_many :messages,
               class_name: "Decidim::DecidimAwesome::FollowUpQuestionnaireMessage",
               dependent: :destroy,
               inverse_of: :follow_up_questionnaire

      validates :decidim_questionnaire_id, uniqueness: true
      validates :name, presence: true
      validates :position, presence: true
      validates :active, inclusion: { in: [true, false] }

      scope :ordered, -> { order(active: :desc, position: :asc, id: :asc) }
      scope :active, -> { where(active: true) }
    end
  end
end
