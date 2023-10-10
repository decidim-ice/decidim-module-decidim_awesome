# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module HasVoteWeight
      extend ActiveSupport::Concern

      included do
        has_one :vote_weight, foreign_key: "proposal_vote_id", class_name: "Decidim::DecidimAwesome::VoteWeight", dependent: :destroy
      end
    end
  end
end
