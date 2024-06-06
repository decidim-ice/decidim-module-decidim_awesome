# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module HasProposalExtraFields
      extend ActiveSupport::Concern

      included do
        has_one :extra_fields, foreign_key: "decidim_proposal_id", class_name: "Decidim::DecidimAwesome::ProposalExtraField", dependent: :destroy

        def private_body
          extra_fields ||= initialized_extra_fields
          extra_fields.private_body
        end

        def update_private_body(updated_private_body)
          extra_fields ||= initialized_extra_fields
          extra_fields.update!(private_body: updated_private_body)
          extra_fields
        end
        
        def remove_private_body
          extra_fields ||= initialized_extra_fields
          extra_fields.update!(private_body: {})
          extra_fields
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

        def update_vote_weights!
          extra_fields ||= initialized_extra_fields
          votes.each do |vote|
            extra_fields.vote_weight_totals[vote.weight] ||= 0
            extra_fields.vote_weight_totals[vote.weight] += 1
          end
          extra_fields.save!
          self.extra_fields = extra_fields
          @vote_weights = nil
          @all_vote_weights = nil
        end

        # collects all different weights stored along the different proposals in a different component
        def self.all_vote_weights_for(component)
          Decidim::DecidimAwesome::VoteWeight.where(
            proposal_vote_id: Decidim::Proposals::ProposalVote.where(
              proposal: Decidim::Proposals::Proposal.where(component:)
            )
          ).pluck(:weight)
        end

        private

        def initialized_extra_fields
          extra_fields ||= Decidim::DecidimAwesome::ProposalExtraField.find_or_initialize_by(proposal: self) do |extra_fields|
            extra_fields.vote_weight_totals = {}
            extra_fields.private_body = {}
          end
          extra_fields
        end
      end
    end
  end
end
