# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module HasCookieCategories
      def decidim_defaults
        CookieManagementStore.decidim_defaults
      end

      def default_category_slugs
        @default_category_slugs ||= Decidim.consent_categories.map { |cat| cat[:slug].to_s }
      end

      def reset_category_to_default(slug)
        decidim_defaults.find { |c| c["slug"] == slug.to_s }
      end

      def reset_cookie_item_to_default(category_slug, item_name)
        default_category = decidim_defaults.find { |c| c["slug"] == category_slug.to_s }
        return nil unless default_category

        default_category["items"].find { |i| i["name"] == item_name.to_s }
      end
    end
  end
end
