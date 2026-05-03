# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Voting
      # Prepended into VotingCardsProposalVoteCell so that when the proposal is
      # restricted by the "votes by proposal status" filter we render the
      # same :not_allowed template used by the standard ProposalVoteCell,
      # instead of the voting cards UI.
      module VotingCardsProposalVoteCellOverride
        def show
          return render(:not_allowed) if awesome_voting_restricted_by_status?(resource)

          super
        end
      end
    end
  end
end
