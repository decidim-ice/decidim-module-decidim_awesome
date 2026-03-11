# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class CookieManagementStore
      include HasCookieCategories

      def initialize(organization)
        @organization = organization
      end

      def current_categories
        stored_categories.map { |hash| CookieCategory.new(hash, @organization) }
      end

      def stored_categories
        categories_data["categories"]
      end

      def find_category(slug)
        category = stored_categories.find { |c| c["slug"].to_s == slug.to_s }
        CookieCategory.new(category, @organization) if category
      end

      def save!(categories)
        setting.value = { "categories" => categories }
        setting.save!
        @categories_data = nil
      end

      def ensure_initialized!
        existing_slugs = stored_categories.map { |c| c["slug"].to_s }
        missing_defaults = default_decidim_categories.reject { |c| existing_slugs.include?(c["slug"].to_s) }
        return if missing_defaults.empty?

        save!(stored_categories + missing_defaults)
      end

      private

      def setting
        @setting ||= AwesomeConfig.find_or_initialize_by(
          var: :cookie_management,
          organization: @organization
        )
      end

      def categories_data
        @categories_data ||= begin
          data = setting.value
          data = {} unless data.is_a?(Hash)
          data["categories"] = [] unless data["categories"].is_a?(Array)
          data
        end
      end
    end
  end
end
