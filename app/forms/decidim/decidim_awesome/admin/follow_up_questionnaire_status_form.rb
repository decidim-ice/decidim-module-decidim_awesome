# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class FollowUpQuestionnaireStatusForm < Decidim::Form
        attribute :follow_up_questionnaire_id, Integer
        translatable_attribute :name, String
        attribute :color, String

        validates :follow_up_questionnaire_id, presence: true, numericality: { only_integer: true }
        validates :name, translatable_presence: true
        validates :color, presence: true,
                          format: { with: /\A#[0-9a-fA-F]{6}\z/, allow_blank: true }

        validate :name_unique_within_questionnaire, if: -> { follow_up_questionnaire_id.present? && name.present? }

        def map_model(model)
          self.follow_up_questionnaire_id = model.follow_up_questionnaire_id
          self.name = model.name
          self.color = model.color
        end

        def to_params
          {
            :follow_up_questionnaire_id => follow_up_questionnaire_id,
            :name => name,
            :color => color
          }
        end

        def error_message
          errors.full_messages.join(", ")
        end

        private

        def name_unique_within_questionnaire
          statuses = Decidim::DecidimAwesome::FollowUpQuestionnaireStatus
                     .where(follow_up_questionnaire_id:)
                     .where.not(id: context[:current_status_id])
          duplicated = statuses.any? do |status|
            name.any? do |locale, value|
              value.present? && status.name[locale.to_s].to_s.strip.casecmp?(value.to_s.strip)
            end
          end
          errors.add(:base, :taken, message: I18n.t("decidim.decidim_awesome.admin.follow_up_questionnaire_statuses.form.name_taken_error")) if duplicated
        end
      end
    end
  end
end
