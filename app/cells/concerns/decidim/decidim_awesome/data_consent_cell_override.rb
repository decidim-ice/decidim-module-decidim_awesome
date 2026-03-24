# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module DataConsentCellOverride
      # [ {
      #    slug: "essential",
      #    mandatory: true,
      #    title: "Essential cookies",
      #    description: "These cookies are necessary for the website to function and cannot be switched"
      #    visibility: visible
      #    items: [
      #      { type: "cookie", name: "_session_id", service: "this page", description: "Session ID cookie", expiration: ... },
      #      { type: "cookie", name: "decidim-consent", service: "this page", description: "Consent cookie", expiration: ... },
      #      { type: "local_storage", name: "pwaInstallPromptSeen", service: "this page", description: "PWA install prompt seen", expiration: ... }
      #    ]
      #  }, etc... ]

      def categories
        @categories ||= CookieManagementStore.new(model, awesome_categories).categories.values.map do |category|
          next if category["visibility"] == "hidden"

          category.tap do |cat|
            cat["title"] = translated_attribute(category["title"])
            cat["description"] = translated_attribute(category["description"])
            cat["items"] = cat["items"].values.map do |item|
              item.tap do |i|
                i["service"] = translated_attribute(i["service"])
                i["description"] = translated_attribute(i["description"])
                i["expiration"] = translated_attribute(i["expiration"])
              end
            end.compact
          end
        end.compact
      end

      private

      def awesome_categories
        Decidim::DecidimAwesome::AwesomeConfig.find_by(organization: model, var: :cookie_management)&.value
      end
    end
  end
end
