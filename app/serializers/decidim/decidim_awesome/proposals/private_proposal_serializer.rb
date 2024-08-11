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
            payload["notes/#{note.id}".to_sym] = {
              created_at: note.created_at,
              note: note.body,
              author: author_name(note.author)
            }
          end
          payload
        end

        def author_name(author)
          if author.respond_to?(:name)
            translated_attribute(author.name) # is a Decidim::User or Decidim::Organization or Decidim::UserGroup
          elsif author.respond_to?(:title)
            translated_attribute(author.title) # is a Decidim::Meetings::Meeting
          end
        end
      end
    end
  end
end
