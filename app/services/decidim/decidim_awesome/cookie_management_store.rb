# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class CookieManagementStore
      include HasCookieCategories

      def initialize(organization, current_config = nil)
        @organization = organization
        @current_config = current_config || {}
        @decidim_defaults = Decidim.consent_categories || {}
      end

      attr_reader :organization, :current_config, :decidim_defaults

      def categories
        @categories ||= @decidim_defaults.merge(current_config).map do |category|
          sanitize_category(category)
        end
      end

      private

      def sanitize_category(category)
        {
          slug: category["slug"],
          mandatory: category["mandatory"] || false,
          items: (category["items"] || []).map do |item|
            {
              type: item["type"],
              name: item["name"],
              visible: item.fetch("visible", true),
              essential: item.fetch("essential", false),
              expiration: item["expiration"]
            }
          end
        }
      end
    end
  end
end
