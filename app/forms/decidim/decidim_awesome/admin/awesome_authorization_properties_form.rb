# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class AwesomeAuthorizationPropertiesForm < Decidim::Form
        include Decidim::TranslatableAttributes
        translatable_attribute :name, String
        translatable_attribute :explanation, String

        validate :name_max_length
        validate :explanation_max_length

        # checks if values are empty for the organization's locale, if so, it will be considered empty and the config var will be deleted
        def empty?
          locale = current_organization.default_locale.to_s

          name[locale].blank? && explanation[locale].blank?
        end

        private

        def name_max_length
          return unless translated_too_long?(name, 255)

          errors.add(:name, :too_long, count: 255)
        end

        def explanation_max_length
          return unless translated_too_long?(explanation, 1000)

          errors.add(:explanation, :too_long, count: 1000)
        end

        def translated_too_long?(value, max_length)
          value.to_h.values.any? { |text| text.to_s.length > max_length }
        end
      end
    end
  end
end
