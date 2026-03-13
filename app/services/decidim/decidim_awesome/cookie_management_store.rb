# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class CookieManagementStore
      def initialize(organization, current_config = nil)
        @organization = organization
        @current_config = current_config || {}
        @decidim_defaults = build_defaults
      end

      def categories
        @categories ||= begin
          defaults = @decidim_defaults.index_by { |category| category["slug"] }
          custom = Array(@current_config["categories"]).index_by { |category| category["slug"].to_s }
          defaults.merge(custom).values.map do |category|
            CookieCategory.new(category, organization)
          end
        end
      end

      def find_category(slug)
        categories.find { |cat| cat.slug == slug.to_s }
      end

      def stored_categories
        @stored_categories ||= begin
          config = AwesomeConfig.find_or_initialize_by(organization: organization, var: :cookie_management)
          config.value ||= { "categories" => [] }
          config.value["categories"]
        end
      end

      def save!(categories_data)
        config = AwesomeConfig.find_or_initialize_by(organization: organization, var: :cookie_management)
        config.value = { "categories" => categories_data }
        config.save!
      end

      def self.decidim_defaults
        (Decidim.consent_categories || []).map do |category|
          slug = category[:slug].to_s
          {
            "slug" => slug,
            "mandatory" => category[:mandatory] || false,
            "visibility" => "default",
            "title" => localized_translation("layouts.decidim.data_consent.modal.#{slug}.title"),
            "description" => localized_translation("layouts.decidim.data_consent.modal.#{slug}.description"),
            "items" => (category[:items] || []).map do |item|
              name = item[:name].to_s
              {
                "name" => name,
                "type" => item[:type].to_s,
                "service" => localized_translation("layouts.decidim.data_consent.details.items.#{name}.service"),
                "description" => localized_translation("layouts.decidim.data_consent.details.items.#{name}.description"),
                "expiration" => localized_translation("layouts.decidim.data_consent.details.items.#{name}.expiration")
              }
            end
          }
        end
      end

      def self.localized_translation(key)
        I18n.available_locales.each_with_object({}) do |locale, hash|
          hash[locale.to_s] = I18n.t(key, locale: locale, default: "")
        end
      end

      private

      attr_reader :organization, :current_config, :decidim_defaults

      def build_defaults
        self.class.decidim_defaults
      end
    end
  end
end
