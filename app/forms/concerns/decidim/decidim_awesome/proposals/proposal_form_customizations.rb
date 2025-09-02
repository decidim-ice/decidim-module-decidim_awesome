# frozen_string_literal: true

# Recreate validations to take into account custom fields and ignore the length limit in proposals
module Decidim
  module DecidimAwesome
    module Proposals
      module ProposalFormCustomizations
        extend ActiveSupport::Concern

        include ProposalFormCustomizationsBase

        class_methods do
          def overridden_validate_callbacks
            _validate_callbacks.filter do |callback|
              filter = callback.filter
              attributes = filter.try(:attributes)
              unless filter.is_a?(EtiquetteValidator) || filter.is_a?(ActiveModel::Validations::LengthValidator) || filter.is_a?(ProposalLengthValidator) || filter.is_a?(ActiveModel::Validations::PresenceValidator)
                next
              end

              next unless attributes

              attributes.include?(:title) || attributes.include?(:body)
            end
          end

          # remove presence, length and etiquette validators from :title and :body
          def clear_overridden_validators!
            _validators.delete(:title)
            _validators.delete(:body)

            overridden_validate_callbacks.each do |callback|
              _validate_callbacks.delete(callback)
            end
          end
        end

        included do
          clear_overridden_validators!

          validates :title, presence: true, etiquette: true
          validates :title, proposal_length: {
            minimum: ->(form) { form.minimum_title_length },
            maximum: 150
          }

          validates :body, presence: true, unless: ->(form) { form.override_validations? || form.minimum_body_length.zero? }
          validates :body, etiquette: true, unless: ->(form) { form.override_validations? }
          validates :body, proposal_length: {
            minimum: ->(form) { form.minimum_body_length },
            maximum: ->(form) { form.override_validations? ? 0 : form.component.settings.proposal_length }
          }
        end
      end
    end
  end
end
