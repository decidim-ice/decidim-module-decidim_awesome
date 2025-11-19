# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Voting
      # Cell for voting cards in proposals list (index page)
      class VotingCardsProposalListCell < VotingCardsProposalCell
        def from_proposals_list
          true
        end
      end
    end
  end
end
