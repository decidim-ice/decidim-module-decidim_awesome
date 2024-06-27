# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    ##
    # Decorate the serialization method to add one custom field
    # per column in export.
    module ProposalSerializerDecorator
      extend ActiveSupport::Concern
      included do |base|
        base.include(::Decidim::DecidimAwesome::NeedsAwesomeConfig)
        alias_method :decidim_original_serialize, :serialize

        def serialize
          # serialize first the custom fields,
          # as default serialization will strip proposal body's <xml> tags.
          default_serialization = decidim_original_serialize
          default_serialization[:weights] = proposal_vote_weights
          serialized_custom_fields = serialize_custom_fields
          default_serialization.merge(serialized_custom_fields)
        end

        # Override the NeedsAwesomeConfig's awesome_config_instance,
        # to take context from proposal instead of controller's request.
        def awesome_config_instance
          return @config if @config

          @config = Config.new(proposal.organization)
          @config.context_from_component(proposal.component)
          @config
        end

        private

        def proposal_vote_weights
          proposal.update_vote_weights!
          proposal.reload.vote_weights
        end

        def serialize_custom_fields
          payload = {}
          custom_fields = CustomFields.new(awesome_proposal_custom_fields)
          if custom_fields.present?
            @proposal.body.keys.each do |locale|
              fields_entries(custom_fields, proposal.body, locale.to_s) do |key, value|
                value = value.first if value.is_a? Array
                payload["field/#{key}".to_sym] = value
              end
            end
          end
          payload
        end

        # Iterate on custom fields that has a label and name
        # (will ignore paragraphs and title)
        def fields_entries(custom_fields, body, locale)
          custom_fields.apply_xml(body[locale])
          custom_fields.fields.each do |field|
            yield "#{field["label"].parameterize}/#{locale}", field["userData"] if field["label"] && field["name"]
          end
        end
      end
    end
  end
end
