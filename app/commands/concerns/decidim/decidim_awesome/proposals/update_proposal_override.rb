# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Proposals
      ##
      # Decorates update draft and update proposal
      # to avoid private field to be logged in PaperTrail.
      module UpdateProposalOverride
        extend ActiveSupport::Concern
        include ::Decidim::DecidimAwesome::Proposals::Admin::UpdateProposalOverride

        included do
          private

          alias_method :decidim_original_update_draft, :update_draft

          def update_draft
            decidim_original_update_draft
            update_private_field!
          end
        end
      end
    end
  end
end
