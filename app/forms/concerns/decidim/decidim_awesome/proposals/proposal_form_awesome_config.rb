# frozen_string_literal: true

# Recreate validations to take into account custom fields and ignore the length limit in proposals
module Decidim
  module DecidimAwesome
    module Proposals
      module ProposalFormAwesomeConfig
        extend ActiveSupport::Concern

        included do
          def awesome_config
            @awesome_config ||= begin
              conf = Decidim::DecidimAwesome::Config.new(context.current_organization)
              conf.context_from_component(context.current_component)
              conf
            end
          end
        end
      end
    end
  end
end
