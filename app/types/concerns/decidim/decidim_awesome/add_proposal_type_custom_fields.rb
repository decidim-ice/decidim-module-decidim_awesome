# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module AddProposalTypeCustomFields
      extend ActiveSupport::Concern

      included do
        include ::Decidim::DecidimAwesome::NeedsAwesomeConfig

        field :body_fields, TranslatedCustomFieldsType, "Custom fields for this proposal", null: true

        def body_fields
          return if custom_fields.empty?

          @body_fields ||= object.body.transform_values do |body|
            sanitize_translated_fields(body)
          end
        end

        # Override the NeedsAwesomeConfig's awesome_config_instance,
        # to take context from proposal instead of controller's request.
        def awesome_config_instance
          return @custom_config if @custom_config

          @custom_config = Config.new(object.organization)
          @custom_config.context_from_component!(object.component)
          @custom_config.application_context!(current_user: object.creator) if object.respond_to?(:creator)
          @custom_config
        end

        private

        def custom_fields
          @custom_fields ||= CustomFields.new(awesome_proposal_custom_fields)
        end

        def fields_for_xml(body)
          custom_fields.apply_xml(body)
          custom_fields.fields.filter_map do |field|
            next unless field["label"].present? && field.has_key?("name")

            field["userData"] = field["userData"].first if field["userData"].is_a?(Array)
            field.dup
          end
        end

        def sanitize_translated_fields(body)
          if body.is_a?(Hash)
            body.transform_values do |value|
              fields_for_xml(value)
            end
          else
            fields_for_xml(body)
          end
        end
      end
    end
  end
end
