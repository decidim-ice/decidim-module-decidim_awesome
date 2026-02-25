# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module HasCookieCategories
      def default_decidim_categories
        Decidim.consent_categories.map do |cat|
          {
            "slug" => cat[:slug].to_s,
            "mandatory" => cat[:mandatory] || false,
            "title" => {},
            "description" => {},
            "items" => (cat[:items] || []).map { |item| { "name" => item[:name].to_s, "type" => item[:type].to_s } }
          }
        end
      end

      def normalize_category(category)
        {
          slug: category["slug"].to_sym,
          mandatory: category["mandatory"] || false,
          title: translate_attribute(category, "title"),
          description: translate_attribute(category, "description"),
          items: normalize_items(category["items"] || [])
        }
      end

      def normalize_items(items)
        items.map do |item|
          {
            name: item["name"].to_sym,
            type: item["type"].to_sym,
            service: translate_item_attribute(item, "service"),
            description: translate_item_attribute(item, "description")
          }
        end
      end

      def translate_attribute(category, attribute)
        translations = category[attribute]
        return nil if translations.blank? || !translations.is_a?(Hash)

        translated = translations[I18n.locale.to_s].presence || translations[I18n.default_locale.to_s].presence
        return nil if translated.blank?

        translated
      end

      def translate_item_attribute(item, attribute)
        translations = item[attribute]
        return nil if translations.blank? || !translations.is_a?(Hash)

        translated = translations[I18n.locale.to_s].presence || translations[I18n.default_locale.to_s].presence
        return nil if translated.blank?

        translated
      end

      def translate_category_attribute(category, attribute, slug, organization = nil)
        value = category[attribute]
        return value if value.is_a?(String)
        return I18n.t("layouts.decidim.data_consent.modal.#{slug}.#{attribute}") if value.blank?

        locale = organization&.default_locale || I18n.default_locale
        value[I18n.locale.to_s] ||
          value[locale.to_s] ||
          value.values.compact_blank.first ||
          I18n.t("layouts.decidim.data_consent.modal.#{slug}.#{attribute}")
      end

      def normalize_cookie_item(item)
        {
          type: item["type"].presence || "cookie",
          name: item["name"],
          service: translate_item_attribute(item, "service"),
          description: translate_item_attribute(item, "description")
        }
      end

      def normalize_category_with_i18n(category, organization = nil)
        {
          slug: category["slug"],
          title: translate_category_attribute(category, "title", category["slug"], organization),
          description: translate_category_attribute(category, "description", category["slug"], organization),
          mandatory: category["mandatory"] || false,
          items: (category["items"] || []).map { |item| normalize_cookie_item(item) }
        }
      end
    end
  end
end
