# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Proposals
      module ProposalFormCustomizationsBase
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
