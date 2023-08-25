# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      module PermissionsOverride
        extend ActiveSupport::Concern

        included do
          private

          def admin_edition_is_available?
            return unless proposal

            if proposal_imported? && allow_to_edit_proposals_after_import_enabled?
              true
            else
              (proposal.official? || proposal.official_meeting?) && proposal.votes.empty?
            end
          end

          def proposal_imported?
            Decidim::ResourceLink.exists?(
              name: "copied_from_component",
              to_type: "Decidim::Proposals::Proposal",
              to_id: proposal.id
            )
          end

          def allow_to_edit_proposals_after_import_enabled?
            Decidim::DecidimAwesome::AwesomeConfig.find_by(var: :allow_to_edit_proposals_after_import)&.value == true
          end
        end
      end
    end
  end
end
