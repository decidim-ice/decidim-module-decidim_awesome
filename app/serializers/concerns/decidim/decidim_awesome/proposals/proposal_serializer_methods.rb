# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Proposals
      # Adds one custom field per column in export if custom fields are activted
      # Adds vote weights
      module ProposalSerializerMethods
        extend ActiveSupport::Concern

        included do
          include ::Decidim::DecidimAwesome::NeedsAwesomeConfig

          # Override the NeedsAwesomeConfig's awesome_config_instance,
          # to take context from proposal instead of controller's request.
          def awesome_config_instance
            return @custom_config if @custom_config

            @custom_config = Config.new(proposal.organization)
            @custom_config.context_from_component(proposal.component)
            @custom_config
          end

          def serialize_custom_fields
            payload = {}
            custom_fields = CustomFields.new(awesome_proposal_custom_fields)
            if custom_fields.present?
              @proposal.body.each do |locale, body|
                if body.is_a?(Hash)
                  body.each do |translation_locale, value|
                    fields_entries(custom_fields, value) do |field_key, field_value|
                      payload[:"body/#{field_key}/#{translation_locale}"] = field_value if payload[:"body/#{field_key}/#{translation_locale}"].blank?
                    end
                  end
                else
                  fields_entries(custom_fields, body) do |key, value|
                    payload[:"body/#{key}/#{locale}"] = value
                  end
                end
              end
            end
            payload
          end

          def serialize_private_custom_fields
            payload = {}
            private_custom_fields = CustomFields.new(awesome_proposal_private_custom_fields)
            if private_custom_fields.present?
              fields_entries(private_custom_fields, proposal.private_body) do |key, value|
                value = value.first if value.is_a? Array
                payload[:"private_body/#{key}"] = value
              end
            end
            payload
          end

          # Iterate on custom fields that has a label and name
          # (will ignore paragraphs and title)
          def fields_entries(custom_fields, body)
            custom_fields.apply_xml(body)
            custom_fields.fields.each do |field|
              next unless field["label"].present? && field.has_key?("name")

              value = field["userData"].is_a?(Array) ? field["userData"].first : field["userData"]
              yield field["label"].parameterize, value
            end
          end
        end
      end
    end
  end
end
