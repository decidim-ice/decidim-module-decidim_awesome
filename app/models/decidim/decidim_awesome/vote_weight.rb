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
        extra = Decidim::DecidimAwesome::ProposalExtraField.find_or_initialize_by(proposal: proposal)
        extra.vote_weights_totals = extra.vote_weights_totals || {}

        prev = weight_previous_change&.first
        if prev.present?
          extra.vote_weights_totals[prev.to_s] = Decidim::DecidimAwesome::VoteWeight.where(vote: proposal.votes, weight: prev).count
          extra.vote_weights_totals.delete(prev.to_s) if extra.vote_weights_totals[prev.to_s].zero?
        end
        extra.vote_weights_totals[weight.to_s] = Decidim::DecidimAwesome::VoteWeight.where(vote: proposal.votes, weight: weight).count
        extra.vote_weights_totals.delete(weight.to_s) if extra.vote_weights_totals[weight.to_s].zero?
        extra.weight_total = extra.vote_weights_totals.inject(0) { |sum, (weight, count)| sum + (weight.to_i * count) }
        extra.save!
      end
    end
  end
end
