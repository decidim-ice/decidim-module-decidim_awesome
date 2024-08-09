# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Proposals
      ##
      # Decorates update draft and update proposal
      # to avoid private field to be logged in PaperTrail.
      module UpdateCollaborativeDraftOverride
        extend ActiveSupport::Concern

        included do
          private

          alias_method :decidim_original_update_collaborative_draft, :update_collaborative_draft

          def update_collaborative_draft
            decidim_original_update_collaborative_draft
            # Update the proposal with the private body, to
            # avoid tracebility on private fields.
            @collaborative_draft.update_private_body!(form.private_body) if form.private_body.present?
          end
        end
      end
    end
  end
end
