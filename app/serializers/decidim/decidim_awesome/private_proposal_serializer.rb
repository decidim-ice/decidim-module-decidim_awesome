# frozen_string_literal: true

module Decidim::DecidimAwesome
  ##
  # Custom serializer for Proposals with private data.
  # Used to separate open-data export and admin export.
  class PrivateProposalSerializer < ::Decidim::Exporters::Serializer
    include NeedsAwesomeConfig

    def initialize(proposal)
      @proposal = proposal
    end

    ##
    # Use the "public" proposal serializer, and add then
    # private fields.
    def serialize
      serialized_proposal = ::Decidim::Proposals::ProposalSerializer.new(@proposal).serialize
      serialize_private_custom_fields(serialized_proposal)
    end

    # override the AwesomeHelper awesome_config_instance to take
    # proposal context and not request context.
    def awesome_config_instance
      return @config if @config

      @config = Config.new(proposal.organization)
      @config.context_from_component(proposal.component)
      @config
    end

    private

    attr_reader :proposal

    def fields_entries(custom_fields, text)
      custom_fields.apply_xml(text)
      custom_fields.fields.each do |field|
        yield field["label"].parameterize.to_s, field["userData"] if field["label"] && field["name"]
      end
    end

    def serialize_private_custom_fields(payload)
      private_custom_fields = CustomFields.new(awesome_private_proposal_custom_fields)
      return payload if private_custom_fields.blank?

      fields_entries(private_custom_fields, proposal.private_body) do |key, value|
        payload["secret/#{key}".to_sym] = value
      end

      payload
    end
  end
end
