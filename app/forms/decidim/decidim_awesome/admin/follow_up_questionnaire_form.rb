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
        attribute :reply_to, String
        attribute :active, Boolean, default: true

        validates :name, translatable_presence: true
        validates :decidim_questionnaire_id, presence: true, numericality: { only_integer: true }
        validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
        validates :reply_to, "valid_email_2/email": true, allow_blank: true
        validate :questionnaire_belongs_to_organization, if: -> { decidim_questionnaire_id.present? }
        validate :questionnaire_not_already_configured, if: -> { decidim_questionnaire_id.present? }
        validate :responder_fields_belong_to_questionnaire, if: -> { decidim_questionnaire_id.present? }

        def map_model(model)
          self.decidim_questionnaire_id = model.decidim_questionnaire_id
          self.position = model.position
          self.responder_name_field = model.responder_name_field
          self.responder_email_field = model.responder_email_field
          self.reply_to = model.reply_to
          self.active = model.active if model.respond_to?(:active)
        end

        def to_params
          {
            :name => name,
            :decidim_questionnaire_id => decidim_questionnaire_id,
            :position => position,
            :responder_name_field => responder_name_field,
            :responder_email_field => responder_email_field,
            :reply_to => reply_to.presence,
            :active => active
          }
        end

        # The component of the survey the questionnaire belongs to, if it is in the current organization
        def component
          return @component if defined?(@component)

          @component = questionnaire && FollowUpQuestionnairesFinder.new(current_organization).component_for(questionnaire)
        end

        private

        def questionnaire
          return @questionnaire if defined?(@questionnaire)

          @questionnaire = Decidim::Forms::Questionnaire.find_by(id: decidim_questionnaire_id)
        end

        def questionnaire_belongs_to_organization
          errors.add(:decidim_questionnaire_id, :invalid) if component.blank?
        end

        def questionnaire_not_already_configured
          return unless context[:existing_questionnaire_ids]&.include?(decidim_questionnaire_id)

          errors.add(:decidim_questionnaire_id, :taken)
        end

        def responder_fields_belong_to_questionnaire
          return if questionnaire.blank?

          question_ids = questionnaire.questions.pluck(:id).map(&:to_s)
          [:responder_name_field, :responder_email_field].each do |field|
            value = public_send(field)
            next if value.blank? || question_ids.include?(value.to_s)

            errors.add(field, :invalid)
          end
        end
      end
    end
  end
end
