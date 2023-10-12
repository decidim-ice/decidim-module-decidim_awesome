# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module HasVoteWeight
      extend ActiveSupport::Concern

      included do
        has_one :vote_weight, foreign_key: "proposal_vote_id", class_name: "Decidim::DecidimAwesome::VoteWeight", dependent: :destroy

        delegate :weight, to: :vote_weight, allow_nil: true

        def weight=(new_weight)
          vote_weight = VoteWeight.find_or_initialize_by(vote: self)
          vote_weight.weight = new_weight
          vote_weight.save
          reload
        end
      end
    end
  end
end
