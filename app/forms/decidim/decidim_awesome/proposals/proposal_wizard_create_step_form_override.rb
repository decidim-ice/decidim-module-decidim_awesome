# frozen_string_literal: true

# Recreate validations to take into account custom fields and ignore the length limit in proposals
module Decidim
  module DecidimAwesome
    module Proposals
      module ProposalWizardCreateStepFormOverride
        extend ActiveSupport::Concern

        included do
          clear_validators!

          validates :title, presence: true, etiquette: true
          validates :title, length: { in: 15..150 }
          validates :body, presence: true, etiquette: true, unless: ->(form) { form.override_validations? }
          validates :body, proposal_length: {
            minimum: 15,
            maximum: ->(record) { record.override_validations? ? 0 : record.component.settings.proposal_length }
          }

          validate :body_is_not_bare_template, unless: ->(form) { form.override_validations? }

          def override_validations?
            return false if context.current_component.settings.participatory_texts_enabled

            custom_fields.present?
          end

          def custom_fields
            awesome_config = Decidim::DecidimAwesome::Config.new(context.current_organization)
            awesome_config.context_from_component(context.current_component)
            awesome_config.collect_sub_configs_values("proposal_custom_field")
          end
        end
      end
    end
  end
end
