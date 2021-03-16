# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module OverviewComponent
      # This cell renders the Medium (:m) overview card
      # for an given instance of a Component
      class ProposalsCell < OverviewMCell
        def items
          Decidim::Proposals::Proposal.where(component: model)
        end

        def description
          votes_remaining if current_user
        end

        def voted_n_times
          Decidim::Proposals::ProposalVote.where(proposal: items, author: current_user).count
        end

        def votes_remaining
          model.settings.vote_limit - voted_n_times
        end
      end
    end
  end
end
