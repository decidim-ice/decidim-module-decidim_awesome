# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Voting
      # Cell for voting cards on proposal show page
      class VotingCardsProposalShowCell < VotingCardsProposalCell
        def from_proposals_list
          false
        end
      end
    end
  end
end
