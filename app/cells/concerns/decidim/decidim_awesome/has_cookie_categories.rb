# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module HasCookieCategories
      include Decidim::TranslatableAttributes

      def default_decidim_categories
        Decidim.consent_categories.map do |cat|
          slug = cat[:slug].to_s
          {
            "slug" => slug,
            "mandatory" => cat[:mandatory] || false,
            "visibility" => "default",
            "title" => default_translations_for(slug, "title"),
            "description" => default_translations_for(slug, "description"),
            "items" => (cat[:items] || []).map { |item| default_cookie_item(item) }
          }
        end
      end

      def normalize_category(category, organization = nil)
        {
          slug: category["slug"].to_sym,
          mandatory: category["mandatory"] || false,
          title: translated_attribute(category["title"], organization),
          description: translated_attribute(category["description"], organization),
          items: (category["items"] || []).map { |item| CookieItem.new(item, organization).to_frontend_hash(organization) }
        }
      end

      def default_category_slugs
        @default_category_slugs ||= Decidim.consent_categories.map { |cat| cat[:slug].to_s }
      end

      def reset_category_to_default(slug)
        default_decidim_categories.find { |c| c["slug"] == slug.to_s }
      end

      def reset_cookie_item_to_default(category_slug, item_name)
        default_cat = default_decidim_categories.find { |c| c["slug"] == category_slug.to_s }
        return nil unless default_cat

        default_cat["items"].find { |i| i["name"] == item_name.to_s }
      end

      private

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
    end
  end
end
