# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class VoteWeight < ApplicationRecord
      self.table_name = "decidim_awesome_vote_weights"
      belongs_to :vote, foreign_key: "proposal_vote_id", class_name: "Decidim::Proposals::ProposalVote"

      delegate :proposal, to: :vote

      after_destroy :update_vote_weight_totals!
      after_save :update_vote_weight_totals!

      def update_vote_weight_totals!
        cache = Decidim::DecidimAwesome::WeightCache.find_or_initialize_by(proposal: proposal)
        cache.totals = cache.totals || {}

        prev = weight_previous_change&.first
        if prev.present?
          cache.totals[prev.to_s] = Decidim::DecidimAwesome::VoteWeight.where(vote: proposal.votes, weight: prev).count
          cache.totals.delete(prev.to_s) if cache.totals[prev.to_s].zero?
        end
        cache.totals[weight.to_s] = Decidim::DecidimAwesome::VoteWeight.where(vote: proposal.votes, weight: weight).count
        cache.totals.delete(weight.to_s) if cache.totals[weight.to_s].zero?
        cache.weight_total = cache.totals.inject(0) { |sum, (weight, count)| sum + (weight.to_i * count) }
        cache.save!
      end
    end
  end
end
