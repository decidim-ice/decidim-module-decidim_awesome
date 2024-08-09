# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Proposals
      ##
      # Override Proposal Presenter to access private field.
      module ProposalPresenterOverride
        extend ActiveSupport::Concern
        included do
          def private_body(*)
            return unless proposal

            proposal.private_body
          end
        end
      end
    end
  end
end
