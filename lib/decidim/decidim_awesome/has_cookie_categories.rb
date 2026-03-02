# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module HasCookieCategories
      def default_decidim_categories
        Decidim.consent_categories.map do |cat|
          slug = cat[:slug].to_s
          {
            "slug" => slug,
            "mandatory" => cat[:mandatory] || false,
            "title" => default_translations_for(slug, "title"),
            "description" => default_translations_for(slug, "description"),
            "items" => (cat[:items] || []).map { |item| default_cookie_item(item) }
          }
        end
      end

      def default_cookie_item(item)
        item_name = item[:name].to_s
        {
          "name" => item_name,
          "type" => item[:type].to_s,
          "service" => default_item_translations_for(item_name, "service"),
          "description" => default_item_translations_for(item_name, "description")
        }
      end

      def default_item_translations_for(item_name, attribute)
        I18n.available_locales.each_with_object({}) do |locale, hash|
          hash[locale.to_s] = I18n.t(
            "layouts.decidim.data_consent.details.items.#{item_name}.#{attribute}",
            locale: locale,
            default: ""
          )
        end
      end

      def default_translations_for(slug, attribute)
        I18n.available_locales.each_with_object({}) do |locale, hash|
          hash[locale.to_s] = I18n.t(
            "layouts.decidim.data_consent.modal.#{slug}.#{attribute}",
            locale: locale,
            default: ""
          )
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
          "type" => item["type"].presence || "cookie",
          "name" => item["name"],
          "service" => translate_item_attribute(item, "service"),
          "description" => translate_item_attribute(item, "description")
        }
      end

      def normalize_category_with_i18n(category, organization = nil)
        {
          "slug" => category["slug"],
          "title" => translate_category_attribute(category, "title", category["slug"], organization),
          "description" => translate_category_attribute(category, "description", category["slug"], organization),
          "mandatory" => category["mandatory"] || false,
          "items" => (category["items"] || []).map { |item| normalize_cookie_item(item) }
        }
      end

      def default_category_slugs
        @default_category_slugs ||= Decidim.consent_categories.map { |cat| cat[:slug].to_s }
      end

      def default_category?(category)
        slug = category.is_a?(Hash) ? category["slug"] : category
        default_category_slugs.include?(slug.to_s)
      end

      def category_modified?(category)
        return false unless default_category?(category)

        default_cat = default_decidim_categories.find { |c| c["slug"] == category["slug"] }
        return false unless default_cat

        category["title"] != default_cat["title"] ||
          category["description"] != default_cat["description"] ||
          category["mandatory"] != default_cat["mandatory"] ||
          category["items"] != default_cat["items"]
      end

      def reset_category_to_default(slug)
        default_decidim_categories.find { |c| c["slug"] == slug.to_s }
      end

      def category_visible?(category, user = nil)
        visibility = category.is_a?(Hash) ? category["visibility"] : category[:visibility]

        case visibility
        when "hidden"
          false
        when "logged"
          user.present?
        when "non_logged"
          user.blank?
        when "verified_user"
          return false unless user

          Decidim::Authorization.where(user: user).any? { |auth| auth.granted? && !auth.expired? }
        else
          true
        end
      end

      def default_cookie_item?(category_slug, item_name)
        default_cat = default_decidim_categories.find { |c| c["slug"] == category_slug.to_s }
        return false unless default_cat

        default_cat["items"].any? { |item| item["name"] == item_name.to_s }
      end

      def cookie_item_modified?(category_slug, item)
        return false unless default_cookie_item?(category_slug, item["name"])

        default_cat = default_decidim_categories.find { |c| c["slug"] == category_slug.to_s }
        default_item = default_cat["items"].find { |i| i["name"] == item["name"] }
        return false unless default_item

        item["type"] != default_item["type"] ||
          item["service"] != default_item["service"] ||
          item["description"] != default_item["description"]
      end

      def reset_cookie_item_to_default(category_slug, item_name)
        default_cat = default_decidim_categories.find { |c| c["slug"] == category_slug.to_s }
        return nil unless default_cat

        default_cat["items"].find { |i| i["name"] == item_name.to_s }
      end
    end
  end
end
