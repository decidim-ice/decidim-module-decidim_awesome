# frozen_string_literal: true

# Recreate validations to take into account custom fields and ignore the length limit in proposals
module Decidim
  module DecidimAwesome
    module Proposals
      module Admin
        module ProposalFormCustomizations
          extend ActiveSupport::Concern

          include ProposalFormCustomizationsBase

          class_methods do
            def overridden_validators
              _validators.filter do |attribute, _validators|
                attribute.to_s.start_with?("title") || attribute.to_s.start_with?("body")
              end
            end

            def overridden_validate_callbacks
              _validate_callbacks.filter do |callback|
                filter = callback.filter
                if filter.is_a?(ActiveModel::Validations::LengthValidator) ||
                   filter.is_a?(ActiveModel::Validations::PresenceValidator) ||
                   filter.is_a?(TranslatablePresenceValidator)

                  filter.attributes.any? { |attr| attr.to_s.start_with?("title") || attr.to_s.start_with?("body") }
                end
              end
            end

            # remove presence, length and etiquette validators from :title and :body
            def clear_overridden_validators!
              overridden_validators.keys.each do |attribute|
                _validators.delete(attribute)
              end
              overridden_validate_callbacks.each do |callback|
                _validate_callbacks.delete(callback)
              end
            end
          end

          included do
            clear_overridden_validators!

            translatable_attribute :title, String do |field, _locale|
              validates field, proposal_length: {
                minimum: ->(form) { form.minimum_title_length },
                maximum: 150
              }, if: proc { |resource| resource.send(field).present? }
            end

            validates :title, :body, translatable_presence: true, unless: ->(form) { form.override_validations? }
          end
        end
      end
    end
  end
end
