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

              case filter
              when EtiquetteValidator, ActiveModel::Validations::LengthValidator, ProposalLengthValidator, ActiveModel::Validations::PresenceValidator
                filter.attributes.include?(:title) || filter.attributes.include?(:body)
              when :body_is_not_bare_template
                true
              end
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
          validate :body_is_not_bare_template, unless: ->(form) { form.override_validations? }
        end
      end
    end
  end
end
