# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module DataConsentCellOverride
      # [ {
      #    slug: "essential",
      #    mandatory: true,
      #    title: "Essential cookies",
      #    description: "These cookies are necessary for the website to function and cannot be switched"
      #    visibility: default
      #    items: [
      #      { type: "cookie", name: "_session_id", service: "this page", description: "Session ID cookie", expiration: ... },
      #      { type: "cookie", name: "decidim-consent", service: "this page", description: "Consent cookie", expiration: ... },
      #      { type: "local_storage", name: "pwaInstallPromptSeen", service: "this page", description: "PWA install prompt seen", expiration: ... }
      #    ]
      #  }, etc... ]

      def categories
        @categories ||= CookieManagementStore.new(model, awesome_categories).categories.values.map do |category|
          items = category["items"].is_a?(Hash) ? category["items"].values : Array(category["items"])
          category.merge(
            "title" => translated_attribute(category["title"]),
            "description" => translated_attribute(category["description"]),
            "items" => items.map do |item|
              item.merge(
                "service" => translated_attribute(item["service"]),
                "description" => translated_attribute(item["description"])
              )
            end
          )
        end
      end

      private

      def awesome_categories
        value = Decidim::DecidimAwesome::AwesomeConfig.find_by(organization: model, var: :cookie_management)&.value
        return {} unless value.is_a?(Hash)

        categories = value["categories"]
        return value unless categories.is_a?(Array)

        categories.each_with_object({}) { |category, h| h[category["slug"]] = category if category["slug"].present? }
      end
    end
  end
end
