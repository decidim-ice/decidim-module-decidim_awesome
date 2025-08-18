# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class AuthorizationGroupForm < Decidim::Form
        include TranslatableAttributes

        attribute :authorization_handlers, { String => Object }
        attribute :authorization_handlers_names, Array[String]
        attribute :authorization_handlers_options, { String => Object }
        attribute :force_authorization_with_any_method, Boolean, default: false
        translatable_attribute :force_authorization_help_text, String, default: {}

        def verification_settings
          {
            authorization_handlers: parsed_authorization_handlers,
            force_authorization_with_any_method: !force_authorization_with_any_method.nil?,
            force_authorization_help_text: force_authorization_help_text || {}
          }
        end

        def parsed_authorization_handlers
          authorization_handlers_names.filter_map do |name|
            next if name.blank?

            [
              name,
              { options: authorization_handler_options(name) }
            ]
          end.to_h
        end

        def options_schema(handler_name)
          options_manifest(handler_name).schema.new(authorization_handler_options(handler_name))
        end

        def authorization_handlers_names
          super.presence || authorization_handlers.keys.map(&:to_s)
        end

        def authorization_handler_options(handler_name)
          authorization_handlers_options&.dig(handler_name.to_s) || authorization_handlers&.dig(handler_name, "options").presence || {}
        end

        def options_attributes(handler_name)
          manifest = options_manifest(handler_name)
          manifest ? manifest.attributes : []
        end

        def manifest(handler_name)
          Decidim::Verifications.find_workflow_manifest(handler_name)
        end

        def options_manifest(handler_name)
          manifest(handler_name).options
        end

        # Helper for the view, at this point, ephemeral authorizations are not supported
        def available_authorizations
          Decidim.authorization_workflows.filter do |workflow|
            current_organization.available_authorizations.include?(workflow.name) && !workflow.ephemeral?
          end
        end
      end
    end
  end
end
