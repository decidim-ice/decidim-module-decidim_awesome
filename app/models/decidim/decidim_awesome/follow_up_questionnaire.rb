# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class FollowUpQuestionnaire < ApplicationRecord
      include Decidim::TranslatableAttributes
      include Decidim::TranslatableResource

      translatable_fields :name

      self.table_name = "decidim_awesome_follow_up_questionnaires"

      belongs_to :organization,
                 class_name: "Decidim::Organization",
                 foreign_key: :decidim_organization_id

      belongs_to :component,
                 class_name: "Decidim::Component",
                 foreign_key: :decidim_component_id

      belongs_to :questionnaire,
                 class_name: "Decidim::Forms::Questionnaire",
                 foreign_key: :decidim_questionnaire_id

      delegate :participatory_space, to: :component, allow_nil: true

      # Messages go first so they are destroyed before the statuses they use
      has_many :messages,
               class_name: "Decidim::DecidimAwesome::FollowUpQuestionnaireMessage",
               dependent: :destroy,
               inverse_of: :follow_up_questionnaire

      has_many :statuses,
               class_name: "Decidim::DecidimAwesome::FollowUpQuestionnaireStatus",
               dependent: :destroy,
               inverse_of: :follow_up_questionnaire

      validates :decidim_questionnaire_id, uniqueness: true
      validates :name, presence: true
      validates :position, presence: true
      validates :active, inclusion: { in: [true, false] }
      validate :component_belongs_to_organization

      scope :ordered, -> { order(active: :desc, position: :asc, id: :asc) }
      scope :active, -> { where(active: true) }
      # Components in the trash are excluded by their default scope
      scope :visible, -> { where(decidim_component_id: Decidim::Component.unscope(:order).select(:id)) }
      scope :for_space, ->(space) { where(decidim_component_id: space.components.unscope(:order).select(:id)) }

      def removable?
        messages.none?
      end

      # Messages belong to the respondents of the linked survey, so it cannot be changed once there are any
      def questionnaire_editable?
        new_record? || messages.none?
      end

      def number_of_responses
        questionnaire.count_participants
      end

      private

      def component_belongs_to_organization
        return if component.blank? || organization.blank?

        errors.add(:component, :invalid) unless component.organization == organization
      end
    end
  end
end
