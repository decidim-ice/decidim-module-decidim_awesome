# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Proposals
      ##
      # Decorate create_collaborative_draft to avoid
      # private data to be in PaperTrail
      module CreateCollaborativeDraftOverride
        extend ActiveSupport::Concern

        included do
          private

          alias_method :decidim_original_create_collaborative_draft, :create_collaborative_draft

          def create_collaborative_draft
            created_draft = decidim_original_create_collaborative_draft
            # Update the proposal with the private body, to
            # avoid tracebility on private fields.
            created_draft.update_private_body!(form.private_body) if form.private_body.present?
          end
        end
      end
    end
  end
end
