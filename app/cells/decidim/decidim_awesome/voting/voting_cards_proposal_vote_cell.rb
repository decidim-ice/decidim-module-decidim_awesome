# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Voting
      # This cell renders the vote button for voting cards in proposal lists
      class VotingCardsProposalVoteCell < Decidim::Proposals::ProposalVoteCell
        def show
          render
        end
      end
    end
  end
end
