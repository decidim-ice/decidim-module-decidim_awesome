# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module HasVoteWeight
      extend ActiveSupport::Concern

      included do
        has_one :vote_weight, foreign_key: "proposal_vote_id", class_name: "Decidim::DecidimAwesome::VoteWeight", dependent: :destroy

        delegate :weight, to: :vote_weight, allow_nil: true
        delegate :update_vote_weight_totals!, to: :vote_weight, allow_nil: true

        # this is necessary when vote changes from temporary to final
        after_update :update_vote_weight!

        def weight=(new_weight)
          vote_weight = VoteWeight.find_or_initialize_by(vote: self)
          vote_weight.weight = new_weight
          vote_weight.save
          reload
        end

        def update_vote_weight!
          VoteWeight.find_by(vote: self)&.update_vote_weight_totals!
        end
      end
    end
  end
end
