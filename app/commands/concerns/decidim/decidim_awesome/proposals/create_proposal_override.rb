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
            decidim_original_create_proposal
            # Update the proposal with the private body, to
            # avoid tracebility on private fields.
            @proposal.update_private_body!(form.private_body) if form.private_body.present?
          end
        end
      end
    end
  end
end
