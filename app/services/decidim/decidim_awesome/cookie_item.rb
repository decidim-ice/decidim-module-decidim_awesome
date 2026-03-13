# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class CookieItem
      include HasCookieCategories
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
        default_category = decidim_defaults.find { |c| c["slug"] == category_slug.to_s }
        return false unless default_category

        default_category["items"].any? { |i| i["name"] == name }
      end

      def modified?(category_slug)
        return false unless default?(category_slug)

        default_category = decidim_defaults.find { |c| c["slug"] == category_slug.to_s }
        default_item = default_category["items"].find { |i| i["name"] == name }
        return false unless default_item

        type != default_item["type"] ||
          @data["service"] != default_item["service"] ||
          @data["description"] != default_item["description"]
      end

      def to_form_params
        {
          name: name,
          type: type,
          service: service,
          description: description,
          expiration: expiration
        }
      end

      def to_params
        @data
      end

      def sanitize_item(organization = nil)
        {
          "type" => type,
          "name" => name,
          "service" => translated_attribute(@data["service"], organization),
          "description" => translated_attribute(@data["description"], organization),
          "expiration" => expiration
        }
      end
    end
  end
end
