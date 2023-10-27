# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Voting
      class ThreeFlagsProposalCell < ThreeFlagsBaseCell
        VOTE_WEIGHTS = [0, 1, 2, 3].freeze

        def show
          render :show
        end

        def vote_block_for(proposal, weight, color)
          render partial: "vote_block", locals: {
            proposal: proposal,
            weight: weight,
            color: color
          }
        end

        def proposal_votes(weight)
          model.weight_count(weight)
        end

        def voted_for?(option)
          current_vote&.weight == option
        end

        def from_proposals_list
          options[:from_proposals_list]
        end

        def proposal_vote_path(weight)
          proposal_proposal_vote_path(proposal_id: proposal.id, from_proposals_list: from_proposals_list, weight: weight)
        end

        def opacity_class_for(option)
          !voted_for_any? || voted_for?(option) ? "fully-opaque" : "semi-opaque"
        end

        def voted_for_any?
          VOTE_WEIGHTS.any? { |opt| voted_for?(opt) }
        end
      end
    end
  end
end
