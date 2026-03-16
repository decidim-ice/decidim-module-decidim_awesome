# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class CookieCategory
      include Decidim::TranslatableAttributes

      def initialize(hash, organization = nil)
        @data = hash
        @organization = organization
      end

      def slug
        @data["slug"].to_s
      end

      def mandatory?
        @data["mandatory"] || false
      end

      def title
        translated_attribute(@data["title"], @organization)
      end

      def description
        translated_attribute(@data["description"], @organization)
      end

      def visibility
        @data["visibility"]
      end

      def default?
        Decidim.consent_categories.map { |cat| cat[:slug].to_s }.include?(slug)
      end

      def modified?
        return false unless default?

        default_category = CookieManagementStore.decidim_defaults.find { |c| c["slug"] == slug }
        return false unless default_category

        @data["title"] != default_category["title"] ||
          @data["description"] != default_category["description"] ||
          @data["mandatory"] != default_category["mandatory"] ||
          @data["visibility"] != default_category["visibility"] ||
          @data["items"] != default_category["items"]
      end

      def items
        @items ||= (@data["items"] || []).map { |item| CookieItem.new(item, @organization) }
      end

      def to_form_params
        {
          slug: slug,
          mandatory: mandatory?,
          title: @data["title"],
          description: @data["description"],
          visibility: visibility
        }
      end

      def to_params
        @data
      end

      def sanitize_category
        to_form_params.transform_keys(&:to_s).merge(
          "title" => title,
          "description" => description,
          "items" => items.map(&:sanitize_item)
        )
      end
    end
  end
end
