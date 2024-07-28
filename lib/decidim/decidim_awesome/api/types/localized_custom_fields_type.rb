# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # This type represents a localized string in a single language.
    class LocalizedCustomFieldsType < Decidim::Api::Types::BaseObject
      description "Represents a particular translation of a LocalizedCustomFieldsType"

      field :locale, GraphQL::Types::String, "The standard locale of this translation.", null: false
      field :fields, GraphQL::Types::JSON, "The fields of this translation.", null: true
      field :machine_translated, GraphQL::Types::Boolean, "Whether this string is machine translated or not.", null: false

      def machine_translated
        if object.respond_to?(:machine_translated)
          object.machine_translated.present?
        else
          false
        end
      end
    end
  end
end
