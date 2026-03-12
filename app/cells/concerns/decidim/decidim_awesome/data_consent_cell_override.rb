# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module DataConsentCellOverride
      # [ {
      #    slug: "essential",
      #    mandatory: true,
      #    items: [
      #      { type: "cookie", name: "_session_id", visible: false, essential: true, expiration: ... },
      #      { type: "cookie", name: "decidim-consent" },
      #      { type: "local_storage", name: "pwaInstallPromptSeen" }
      #    ]
      #  }, etc... ]

      def categories
        @categories ||= CookieManagementStore.new(model, awesome_categories).categories
      end

      private

      def awesome_categories
        Decidim::Decidim::DecidimAwesome::AwesomeConfig.find_by(organization: model, var: :cookie_management)&.value
      end
    end
  end
end
