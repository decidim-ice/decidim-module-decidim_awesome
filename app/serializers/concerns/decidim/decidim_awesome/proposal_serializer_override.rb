# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module ProposalSerializerOverride
      extend ActiveSupport::Concern

      included do
        # Public: Exports a hash with the serialized data for this proposal.
        def serialize
          {
            id: proposal.id,
            category: {
              id: proposal.category.try(:id),
              name: proposal.category.try(:name) || empty_translatable
            },
            scope: {
              id: proposal.scope.try(:id),
              name: proposal.scope.try(:name) || empty_translatable
            },
            participatory_space: {
              id: proposal.participatory_space.id,
              url: Decidim::ResourceLocatorPresenter.new(proposal.participatory_space).url
            },
            component: { id: component.id },
            title: proposal.title,
            body: convert_to_plain_text(proposal.body),
            address: proposal.address,
            latitude: proposal.latitude,
            longitude: proposal.longitude,
            state: proposal.state.to_s,
            reference: proposal.reference,
            answer: ensure_translatable(proposal.answer),
            supports: proposal.proposal_votes_count,
            weights: proposal_vote_weights,
            endorsements: {
              total_count: proposal.endorsements.size,
              user_endorsements:
            },
            comments: proposal.comments_count,
            attachments: proposal.attachments.count,
            followers: proposal.follows.size,
            published_at: proposal.published_at,
            url:,
            meeting_urls: meetings,
            related_proposals:,
            is_amend: proposal.emendation?,
            original_proposal: {
              title: proposal&.amendable&.title,
              url: original_proposal_url
            }
          }
        end

        private

        def proposal_vote_weights
          proposal.update_vote_weights!
          proposal.vote_weights
        end
      end
    end
  end
end
