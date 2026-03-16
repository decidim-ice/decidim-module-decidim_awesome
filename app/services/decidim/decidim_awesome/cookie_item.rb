# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class CookieItem
      include Decidim::TranslatableAttributes

      def initialize(hash, organization = nil)
        @data = hash
        @organization = organization
      end

      def name
        @data["name"].to_s
      end

      def type
        @data["type"].to_s
      end

      def service
        translated_attribute(@data["service"], @organization)
      end

      def description
        translated_attribute(@data["description"], @organization)
      end

      def expiration
        @data["expiration"] || CookieManagementStore.localized_translation("layouts.decidim.data_consent.details.items.#{name}.expiration")
      end

      def default?(category_slug)
        find_default_item(category_slug).present?
      end

      def modified?(category_slug)
        return false unless default?(category_slug)

        default_item = find_default_item(category_slug)
        return false unless default_item

        type != default_item["type"] ||
          @data["service"] != default_item["service"] ||
          @data["description"] != default_item["description"]
      end

      def to_form_params
        {
          name: name,
          type: type,
          service: @data["service"],
          description: @data["description"],
          expiration: @data["expiration"]
        }
      end

      def sanitize_item
        to_form_params.transform_keys(&:to_s)
      end

      private

      def find_default_item(category_slug)
        default_category = CookieManagementStore.decidim_defaults.find { |c| c["slug"] == category_slug.to_s }
        default_category&.dig("items")&.find { |i| i["name"] == name }
      end
    end
  end
end
