# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Proposals
      module Admin
        ##
        # Decorates update draft and update proposal
        # to avoid private field to be logged in PaperTrail.
        module UpdateProposalOverride
          extend ActiveSupport::Concern

          included do
            private

            alias_method :decidim_original_update_proposal, :update_proposal

            def update_proposal
              decidim_original_update_proposal
              update_private_field!
            end

            def update_private_field!
              @proposal.update_private_body!(form.private_body) if form.private_body.present?
            end
          end
        end
      end
    end
  end
end
