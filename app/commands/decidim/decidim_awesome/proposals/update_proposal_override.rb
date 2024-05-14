# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Proposals
      ##
      # Decorates update draft and update proposal
      # to avoid private field to be logged in PaperTrail.
      module UpdateProposalOverride
        extend ActiveSupport::Concern

        included do
          private

          alias_method :decidim_original_update_draft, :update_draft
          alias_method :decidim_original_update_proposal, :update_proposal

          def update_draft
            decidim_original_update_draft
            update_private_field
          end

          def update_proposal
            decidim_original_update_proposal
            update_private_field
          end

          def update_private_field
            @proposal.update(
              awesome_private_proposal_field_attributes: { private_body: form.private_body }
            )
            @proposal
          end
        end
      end
    end
  end
end
