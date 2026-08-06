# frozen_string_literal: true

# i18n-tasks-use t('activemodel.attributes.follow_up_questionnaire_statuses.color')
# i18n-tasks-use t('activemodel.attributes.follow_up_questionnaire_statuses.name')
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

      has_many :responses,
               class_name: "Decidim::DecidimAwesome::FollowUpQuestionnaireResponse",
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
