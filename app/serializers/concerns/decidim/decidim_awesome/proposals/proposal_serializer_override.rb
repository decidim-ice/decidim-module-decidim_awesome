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

          def serialize
            # serialize first the custom fields,
            # as default serialization will strip proposal body's <xml> tags.
            serialization = decidim_original_serialize
            serialization.merge!(proposal_vote_weights)
            serialization.merge!(serialize_custom_fields)
          end

          protected

          def proposal_vote_weights
            payload = {}
            if proposal.respond_to?(:vote_weights)
              proposal.update_vote_weights!
              payload[:votes] = proposal.reload.vote_weights
            end
            payload
          end
        end
      end
    end
  end
end
