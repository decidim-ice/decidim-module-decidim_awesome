# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class DataConsentCell < Decidim::DataConsentCell
      include HasCookieCategories

      def category
        render
      end

      def categories
        return @categories if defined?(@categories)

        config_categories = categories_from_config
        awesome = awesome_categories
        @categories =
          if config_categories.blank?
            default_decidim_categories.map { |category| normalize_category_with_i18n(category, model) }
          else
            awesome
          end
      end

      private

      def awesome_categories
        all_categories = categories_from_config || []
        visible_categories = all_categories.reject { |category| category["visibility"] == "hidden" }
        visible_categories.map { |category| normalize_category_with_i18n(category, model) }
      end

      def categories_from_config
        config = AwesomeConfig.find_by(var: "cookie_management", organization: model)
        return nil unless config&.value.is_a?(Hash)

        config.value["categories"]
      end
    end
  end
end
