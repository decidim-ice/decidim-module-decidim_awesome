# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module DataConsentCellOverride
      def categories
        return @categories if defined?(@categories)

        config_categories = categories_from_config
        awesome = awesome_categories
        @categories =
          if config_categories.blank?
            CookieManagementStore.new(model).stored_categories.map { |category| to_frontend_hash(category, model) }
          else
            awesome
          end
      end

      private

      def awesome_categories
        all_categories = categories_from_config || []
        visible_categories = all_categories.reject { |category| category["visibility"] == "hidden" }
        visible_categories.map { |category| to_frontend_hash(category, model) }
      end

      def categories_from_config
        store = CookieManagementStore.new(model)
        store.stored_categories.presence
      end

      def to_frontend_hash(category_hash, organization)
        slug = category_hash["slug"]
        items = (category_hash["items"] || []).map do |item|
          CookieItem.new(item, organization).to_frontend_hash
        end
        {
          "slug" => slug,
          "title" => translated_attribute(category_hash["title"], organization).presence ||
            I18n.t("layouts.decidim.data_consent.modal.#{slug}.title"),
          "description" => translated_attribute(category_hash["description"], organization).presence ||
            I18n.t("layouts.decidim.data_consent.modal.#{slug}.description"),
          "mandatory" => category_hash["mandatory"] || false,
          "items" => items
        }
      end
    end
  end
end
