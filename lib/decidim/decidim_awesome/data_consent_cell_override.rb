# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module DataConsentCellOverride
      def categories
        return @categories if defined?(@categories)

        default_categories = super
        awesome = awesome_categories

        @categories = if awesome.any?
                        merge_categories(default_categories, awesome)
                      else
                        default_categories
                      end
      end

      private

      def merge_categories(default_categories, awesome_categories)
        awesome_by_slug = awesome_categories.index_by { |cat| cat[:slug] }

        merged = default_categories.map do |default_cat|
          awesome_by_slug.delete(default_cat[:slug]) || default_cat
        end

        merged + awesome_by_slug.values
      end

      def awesome_categories
        return [] unless model.is_a?(::Decidim::Organization)

        config = AwesomeConfig.find_by(var: "cookie_management", organization: model)
        return [] unless config&.value.is_a?(Hash)

        config.value["categories"]&.map do |category|
          {
            slug: category["slug"],
            title: translate_attribute(category["title"], category["slug"], :title),
            description: translate_attribute(category["description"], category["slug"], :description),
            mandatory: category["mandatory"] || false,
            items: normalize_items(category["items"] || [])
          }
        end || []
      end

      def normalize_items(items)
        return [] unless items.is_a?(Array)

        items.map do |item|
          {
            type: item["type"].presence || "cookie",
            name: item["name"],
            service: translate_item_attribute(item["service"]),
            description: translate_item_attribute(item["description"])
          }
        end
      end

      def translate_attribute(value, slug, kind)
        return value if value.is_a?(String)
        return t("layouts.decidim.data_consent.modal.#{slug}.#{kind}") if value.blank?

        value[I18n.locale.to_s] ||
          value[model.default_locale.to_s] ||
          value.values.compact_blank.first ||
          t("layouts.decidim.data_consent.modal.#{slug}.#{kind}")
      end

      def translate_item_attribute(value)
        return value if value.is_a?(String)
        return nil if value.blank?

        value[I18n.locale.to_s].presence ||
          value[model.default_locale.to_s].presence ||
          value.values.compact_blank.first.presence
      end
    end
  end
end
