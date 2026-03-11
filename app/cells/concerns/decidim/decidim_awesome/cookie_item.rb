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

      def default?(category_slug)
        default_cat = default_decidim_categories.find { |c| c["slug"] == category_slug.to_s }
        return false unless default_cat

        default_cat["items"].any? { |i| i["name"] == name }
      end

      def modified?(category_slug)
        return false unless default?(category_slug)

        default_cat = default_decidim_categories.find { |c| c["slug"] == category_slug.to_s }
        default_item = default_cat["items"].find { |i| i["name"] == name }
        return false unless default_item

        type != default_item["type"] ||
          @data["service"] != default_item["service"] ||
          @data["description"] != default_item["description"]
      end

      def to_params
        @data
      end

      def to_frontend_hash(organization = nil)
        {
          "type" => type,
          "name" => name,
          "service" => translated_attribute(@data["service"], organization),
          "description" => translated_attribute(@data["description"], organization)
        }
      end
    end
  end
end
