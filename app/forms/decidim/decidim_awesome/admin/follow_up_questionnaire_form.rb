# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class FollowUpQuestionnaireForm < Decidim::Form
        include Decidim::TranslatableAttributes

        translatable_attribute :name, String
        attribute :decidim_questionnaire_id, Integer
        attribute :participatory_space_type, String
        attribute :participatory_space_id, Integer
        attribute :position, Integer, default: 0
        attribute :responder_name, String
        attribute :responder_email, String
        attribute :active, Boolean, default: true

        validates :name, translatable_presence: true
        validates :decidim_questionnaire_id, presence: true, numericality: { only_integer: true }
        validates :participatory_space_type, :participatory_space_id, presence: true
        validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
        validate :questionnaire_not_already_configured, if: -> { decidim_questionnaire_id.present? }

        def map_model(model)
          self.decidim_questionnaire_id = model.decidim_questionnaire_id
          self.participatory_space_type = model.participatory_space_type
          self.participatory_space_id = model.participatory_space_id
          self.position = model.position
          self.responder_name = model.responder_name
          self.responder_email = model.responder_email
          self.active = model.active if model.respond_to?(:active)
        end

        def to_params
          {
            name: name,
            decidim_questionnaire_id: decidim_questionnaire_id,
            participatory_space_type: participatory_space_type,
            participatory_space_id: participatory_space_id,
            position: position,
            responder_name: responder_name,
            responder_email: responder_email,
            active: active
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
