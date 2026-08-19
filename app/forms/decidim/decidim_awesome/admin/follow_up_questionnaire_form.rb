# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class FollowUpQuestionnaireForm < Decidim::Form
        include Decidim::TranslatableAttributes

        translatable_attribute :name, String
        attribute :decidim_questionnaire_id, Integer
        attribute :position, Integer, default: 0
        attribute :responder_name_field, String
        attribute :responder_email_field, String
        attribute :active, Boolean, default: true

        validates :name, translatable_presence: true
        validates :decidim_questionnaire_id, presence: true, numericality: { only_integer: true }
        validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
        validate :questionnaire_not_already_configured, if: -> { decidim_questionnaire_id.present? }

        def map_model(model)
          self.decidim_questionnaire_id = model.decidim_questionnaire_id
          self.position = model.position
          self.responder_name_field = model.responder_name_field
          self.responder_email_field = model.responder_email_field
          self.active = model.active if model.respond_to?(:active)
        end

        def to_params
          {
            :name => name,
            :decidim_questionnaire_id => decidim_questionnaire_id,
            :position => position,
            :responder_name_field => responder_name_field,
            :responder_email_field => responder_email_field,
            :active => active
          }
        end

        private

        def questionnaire_not_already_configured
          return unless context[:existing_questionnaire_ids]&.include?(decidim_questionnaire_id)

          errors.add(:decidim_questionnaire_id, :taken)
        end
      end
    end
  end
end
