# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Proposals
      # Adds one custom field per column in export if custom fields are activted
      # Adds vote weights
      module ProposalSerializerOverride
        extend ActiveSupport::Concern

        included do
          include ProposalSerializerMethods

          alias_method :decidim_original_serialize, :serialize
          alias_method :decidim_original_convert_to_text, :convert_to_text

          def serialize
            # Collect custom fields before core serialization because
            # default serialization strips proposal body's <xml> tags.
            custom_fields = serialize_custom_fields
            serialization = decidim_original_serialize
            serialization.merge!(proposal_vote_weights)
            serialization.merge!(custom_fields)
          end

          # The original convert to text does not parses dt/dd items
          def convert_to_text(text)
            text.gsub!(%r{(</dt>)}i, "\n\\1")
            text.gsub!(%r{[\s]*<dd[^>]*>[\s]*(.*)[\s]*</dd+>}i) do |s|
              s.gsub!(%r{(</div>)}i, "\n\\1")
            end

            decidim_original_convert_to_text(text)
          end

          protected

          # Override the standard `:votes` column with the weighted breakdown
          # whenever the component currently uses a weighted manifest, OR
          # weighted votes already exist (e.g. left over from a previous
          # configuration). When neither is true, return an empty payload so
          # Decidim core's integer vote count is left in place.
          def proposal_vote_weights
            return {} unless should_serialize_weighted_votes?

            proposal.update_vote_weights!
            weights = proposal.reload.vote_weights
            return {} if weights.blank?

            { votes: weights }
          end

          def should_serialize_weighted_votes?
            manifest = awesome_voting_manifest_for(proposal.component)
            return true if manifest&.weighted?

            proposal_votes = Decidim::Proposals::ProposalVote.where(proposal:)
            Decidim::DecidimAwesome::VoteWeight.exists?(proposal_vote_id: proposal_votes.select(:id))
          end
        end
      end
    end
  end
end
