# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class FollowUpQuestionnaireStatus < ApplicationRecord
      include Decidim::Traceable
      include Decidim::TranslatableAttributes
      include Decidim::TranslatableResource

      translatable_fields :name

      self.table_name = "decidim_awesome_follow_up_questionnaire_statuses"

      belongs_to :follow_up_questionnaire,
                 class_name: "Decidim::DecidimAwesome::FollowUpQuestionnaire",
                 inverse_of: :statuses

      has_many :messages,
               class_name: "Decidim::DecidimAwesome::FollowUpQuestionnaireMessage",
               dependent: :restrict_with_exception,
               inverse_of: :status

      validates :name, presence: true, uniqueness: { scope: :follow_up_questionnaire_id }
      validates :color, presence: true

      def self.log_presenter_class_for(_log)
        Decidim::DecidimAwesome::AdminLog::FollowUpQuestionnaireStatusPresenter
      end
    end
  end
end
