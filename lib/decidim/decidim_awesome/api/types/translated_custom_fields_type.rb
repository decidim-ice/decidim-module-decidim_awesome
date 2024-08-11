# frozen_string_literal: true

module Decidim
  module Decidim::DecidimAwesome
    # This type represents a translated field in multiple languages.
    class TranslatedCustomFieldsType < Decidim::Api::Types::BaseObject
      description "A translated field"

      field :locales, [GraphQL::Types::String, { null: true }], description: "Lists all the locales in which this translation is available", null: true

      field :translations, [LocalizedCustomFieldsType, { null: true }], description: "All the localized custom fields for this translation.", null: false do
        argument :locales, [GraphQL::Types::String], description: "A list of locales to scope the translations to.", required: false
      end

      field :translation, GraphQL::Types::JSON, description: "Returns a single translation given a locale.", null: true do
        argument :locale, GraphQL::Types::String, "A locale to search for", required: true
      end

      def locales
        (defined_translations.keys + machine_translations.keys).uniq
      end

      def translation(locale: "")
        display_translations[locale]
      end

      def translations(locales: [])
        translations = display_translations
        translations = translations.slice(*locales) unless locales.empty?
        # rubocop:disable Style/OpenStructUse
        translations.map { |locale, fields| OpenStruct.new(locale: locale, fields: fields, machine_translated: defined_translations[locale].blank?) }
        # rubocop:enable Style/OpenStructUse
      end

      private

      def display_translations
        @display_translations ||= locales.index_with do |locale|
          defined_translations[locale].presence || machine_translations[locale]
        end
      end

      def defined_translations
        object.stringify_keys.except("machine_translations")
      end

      def machine_translations
        object.stringify_keys["machine_translations"]&.stringify_keys || {}
      end
    end
  end
end
