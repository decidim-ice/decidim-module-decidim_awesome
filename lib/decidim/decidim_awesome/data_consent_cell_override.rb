# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module DataConsentCellOverride
      def categories
        awesome_categories = cookie_management_categories
        return awesome_categories if awesome_categories.present?

        super
      end

      private

      def cookie_management_categories
        return [] unless model.is_a?(::Decidim::Organization)

        raw = Decidim::DecidimAwesome::AwesomeConfig.find_by(var: "cookie_management", organization: model)&.value
        categories = raw.is_a?(Hash) ? raw["categories"] : nil
        return [] unless categories.is_a?(Array)

        categories.filter_map do |category|
          next unless category.is_a?(Hash)

          slug = category["slug"].to_s
          next if slug.blank?

          {
            slug: slug,
            title: translated(category["title"], fallback: i18n_category_text(slug, :title)),
            description: translated(category["description"], fallback: i18n_category_text(slug, :description)),
            mandatory: !category["mandatory"].nil?,
            items: normalize_items(category["items"])
          }
        end
      end

      def normalize_items(raw_items)
        return [] unless raw_items.is_a?(Array)

        raw_items.filter_map do |item|
          next unless item.is_a?(Hash)

          name = item["name"].to_s
          next if name.blank?

          {
            type: item["type"].presence || "cookie",
            name:,
            service: translated(item["service"], fallback: i18n_item_text(name, :service)),
            description: translated(item["description"], fallback: i18n_item_text(name, :description))
          }
        end
      end

      def translated(value, fallback: "")
        return fallback if value.blank?
        return value if value.is_a?(String)

        if value.is_a?(Hash)
          (value[I18n.locale.to_s].presence || value[model.default_locale.to_s].presence || value.values.compact_blank.first).to_s.presence || fallback
        else
          fallback
        end
      end

      def i18n_category_text(slug, kind)
        t("layouts.decidim.data_consent.modal.#{slug}.#{kind}")
      end

      def i18n_item_text(name, kind)
        t("layouts.decidim.data_consent.details.items.#{name}.#{kind}")
      end
    end
  end
end
