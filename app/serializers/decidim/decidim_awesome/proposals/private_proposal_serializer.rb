# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Proposals
      ##
      # Custom serializer for Proposals with private data.
      # Used to separate open-data export and admin export.
      class PrivateProposalSerializer < ::Decidim::Proposals::ProposalSerializer
        include ProposalSerializerMethods

        def serialize
          serialization = super.merge!(serialize_private_custom_fields)
          serialization.merge!(serialize_private_notes)
        end

        def serialize_private_notes
          payload = {}
          notes = proposal.notes
          return payload unless notes.any?

          notes.each do |note|
            payload[:"notes/#{note.id}"] = {
              created_at: note.created_at,
              note: note.body,
              author: author_name(note.author)
            }
          end
          payload
        end
      end
    end
  end
end
