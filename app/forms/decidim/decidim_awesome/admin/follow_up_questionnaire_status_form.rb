# frozen_string_literal: true

require "decidim/form"

module Decidim
  module DecidimAwesome
    module Admin
      class FollowUpQuestionnaireStatusForm < Decidim::Form
        
        attribute :follow_up_questionnaire_id, Integer
        attribute :name, String
        attribute :color, String

        validates :follow_up_questionnaire_id, presence: true, numericality: { only_integer: true }
        validates :name, presence: true

        validate :name_unique_within_questionnaire, if: -> { follow_up_questionnaire_id.present? && name.present? }

        def map_model(model)
          self.follow_up_questionnaire_id = model.follow_up_questionnaire_id
          self.name = model.name
          self.color = model.color
        end

        def to_params
          {
          follow_up_questionnaire_id: follow_up_questionnaire_id,
          name: name,
          color: color
          }
        end

        private

        def name_unique_within_questionnaire
          statuses = context[:existing_statuses] || []
          duplicated = statuses.any? do |status|
            status.follow_up_questionnaire_id == follow_up_questionnaire_id &&
            status.name.to_s.strip.casecmp?(name.to_s.strip) &&
            status.id != context[:current_status_id]
          end
          errors.add(:name, :taken) if duplicated
        end
      end
    end
  end
end
