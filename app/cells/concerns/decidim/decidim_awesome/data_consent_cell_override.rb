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
        @categories ||= CookieManagementStore.new(model, awesome_categories).categories.map(&:sanitize_category)
      end

      private

      def awesome_categories
        Decidim::DecidimAwesome::AwesomeConfig.find_by(organization: model, var: :cookie_management)&.value
      end
    end
  end
end
