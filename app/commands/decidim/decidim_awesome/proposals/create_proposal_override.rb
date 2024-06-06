# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Proposals
      ##
      # Decorate create_proposal to avoid
      # private data to be in PaperTrail
      module CreateProposalOverride
        extend ActiveSupport::Concern

        included do
          private

          alias_method :decidim_original_create_proposal, :create_proposal

          def create_proposal
            created_proposal = decidim_original_create_proposal
            # Update the proposal with the private body, to
            # avoid tracebility on private fields.
            created_proposal.update_private_body(
              I18n.locale => form.private_body
            )
          end
        end
      end
    end
  end
end
