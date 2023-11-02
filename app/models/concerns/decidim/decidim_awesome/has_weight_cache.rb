# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module HasWeightCache
      extend ActiveSupport::Concern

      included do
        has_one :weight_cache, foreign_key: "decidim_proposal_id", class_name: "Decidim::DecidimAwesome::WeightCache", dependent: :destroy

        def weight_count(weight)
          (weight_cache && weight_cache.totals[weight.to_s]) || 0
        end

        def vote_weights
          @vote_weights ||= all_vote_weights.to_h { |weight| [manifest&.label_for(weight) || weight.to_s, weight_count(weight)] }
        end

        def manifest
          @manifest ||= DecidimAwesome.voting_registry.find(component.settings.awesome_voting_manifest)
        end

        def all_vote_weights
          @all_vote_weights ||= self.class.all_vote_weights_for(component)
        end

        def update_vote_weights!
          weight_cache ||= Decidim::DecidimAwesome::WeightCache.find_or_initialize_by(proposal: self)
          weight_cache.totals = {}
          votes.each do |vote|
            weight_cache.totals[vote.weight] ||= 0
            weight_cache.totals[vote.weight] += 1
          end
          weight_cache.save!
          self.weight_cache = weight_cache
          @vote_weights = nil
          @all_vote_weights = nil
        end

        # collects all different weights stored along the different proposals in a different component
        def self.all_vote_weights_for(component)
          Decidim::DecidimAwesome::VoteWeight.where(
            proposal_vote_id: Decidim::Proposals::ProposalVote.where(
              proposal: Decidim::Proposals::Proposal.where(component: component)
            )
          ).pluck(:weight)
        end
      end
    end
  end
end
