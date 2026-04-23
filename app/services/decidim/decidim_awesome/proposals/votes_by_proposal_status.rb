# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Proposals
      # Shared logic for the "votes by proposal status" filter.
      # Used by both Decidim::Proposals::Permissions and the view helpers so
      # the rule lives in a single place.
      module VotesByProposalStatus
        module_function

        def active?(settings)
          return false unless Decidim::DecidimAwesome.enabled?(:votes_by_proposal_status)
          return false unless settings.try(:awesome_votes_enabled_by_status)

          allowed_state_ids(settings).any?
        end

        def allowed?(proposal, settings)
          state_id = proposal&.decidim_proposals_proposal_state_id
          return false unless state_id

          allowed_state_ids(settings).include?(state_id.to_i)
        end

        def allowed_state_ids(settings)
          Array(settings.try(:awesome_votes_enabled_states)).compact_blank.map(&:to_i)
        end
      end
    end
  end
end
