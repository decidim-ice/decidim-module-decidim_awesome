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

        unless valid_organization?
          @categories = super
          return @categories
        end

        config_categories = categories_from_config
        awesome = awesome_categories
        @categories =
          if config_categories.blank?
            super
          else
            awesome
          end
      end

      private

      def awesome_categories
        return [] unless valid_organization?

        all_categories = categories_from_config || []
        visible_categories = all_categories.select { |category| category_visible?(category, current_user) }
        visible_categories.map { |category| normalize_category_with_i18n(category, model) }
      end

      def valid_organization?
        model.is_a?(::Decidim::Organization)
      end

      def categories_from_config
        config = AwesomeConfig.find_by(var: "cookie_management", organization: model)
        return nil unless config&.value.is_a?(Hash)

        config.value["categories"]
      end
    end
  end
end
