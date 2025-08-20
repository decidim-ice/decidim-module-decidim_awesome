# frozen_string_literal: true

# Recreate validations to take into account custom fields and ignore the length limit in proposals
module Decidim
  module DecidimAwesome
    module Proposals
      module ProposalFormCustomizations
        extend ActiveSupport::Concern

        included do
          clear_validators!

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

          def override_validations?
            return false if context.current_component.settings.participatory_texts_enabled

            custom_fields.present?
          end

          def minimum_title_length
            awesome_config.config[:validate_title_min_length].to_i
          end

          def minimum_body_length
            awesome_config.config[:validate_body_min_length].to_i
          end

          def custom_fields
            @custom_fields ||= awesome_config.collect_sub_configs_values("proposal_custom_field")
          end

          def awesome_config
            @awesome_config ||= begin
              conf = Decidim::DecidimAwesome::Config.new(context.current_organization)
              conf.context_from_component!(context.current_component)
              conf.application_context!(current_user: context.current_user)
              conf
            end
          end
        end
      end
    end
  end
end
