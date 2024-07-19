# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module HasProposalExtraFields
      extend ActiveSupport::Concern

      included do
        has_one :extra_fields, foreign_key: "decidim_proposal_id", class_name: "Decidim::DecidimAwesome::ProposalExtraField", dependent: :destroy

        after_save do |proposal|
          if proposal.extra_fields && proposal.extra_fields.changed?
            proposal.extra_fields.save
            proposal.update_vote_weights
            proposal.reload
          end
        end

        delegate :private_body=, to: :safe_extra_fields

        def private_body
          extra_fields.private_body if extra_fields
        end

        def update_private_body!(private_body)
          safe_extra_fields.private_body = private_body
          safe_extra_fields.save!
          self.extra_fields = safe_extra_fields
        end

        def weight_count(weight)
          (extra_fields && extra_fields.vote_weight_totals[weight.to_s]) || 0
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

        def update_vote_weights
          votes = Decidim::Proposals::ProposalVote.where(proposal: self)
          safe_extra_fields.vote_weight_totals = {}
          votes.each do |vote|
            safe_extra_fields.vote_weight_totals[vote.weight] ||= 0
            safe_extra_fields.vote_weight_totals[vote.weight] += 1
          end
          @vote_weights = nil
          @all_vote_weights = nil
        end

        def update_vote_weights!
          update_vote_weights
          safe_extra_fields.save!
          self.extra_fields = safe_extra_fields
        end

        def safe_extra_fields
          @safe_extra_fields ||= reload.extra_fields || build_extra_fields
        end

        # collects all different weights stored along the different proposals in a different component
        def self.all_vote_weights_for(component)
          Decidim::DecidimAwesome::VoteWeight.where(
            proposal_vote_id: Decidim::Proposals::ProposalVote.where(
              proposal: Decidim::Proposals::Proposal.where(component:)
            )
          ).pluck(:weight)
        end
      end
    end
  end
end
