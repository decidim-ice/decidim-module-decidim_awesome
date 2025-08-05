# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class AuthorizationGroupForm < Decidim::Form
        include TranslatableAttributes

        attribute :authorization_handlers, Array, default: []
        attribute :authorization_handlers_options, Hash, default: {}
        attribute :force_authorization_with_any_method, Boolean, default: false
        translatable_attribute :force_authorization_help_text, String, default: {}

        def to_h
          {
            "authorization_handlers" => Array(authorization_handlers),
            "authorization_handlers_options" => authorization_handlers_options || {},
            "force_authorization_with_any_method" => !force_authorization_with_any_method.nil?,
            "force_authorization_help_text" => force_authorization_help_text || {}
          }
        end

        def options_schema(handler_name)
          options_manifest(handler_name).schema.new(authorization_handler_options(handler_name))
        end

        def options_attributes(handler_name)
          manifest = options_manifest(handler_name)
          manifest ? manifest.attributes : []
        end

        def authorization_handler_options(handler_name)
          authorization_handlers_options&.dig(handler_name.to_s) || {}
        end

        def manifest(handler_name)
          Decidim::Verifications.find_workflow_manifest(handler_name)
        end

        def options_manifest(handler_name)
          manifest(handler_name).options
        end
      end
    end
  end
end
