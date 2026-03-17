# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class CookieManagementStore
      def initialize(organization, config = nil)
        @organization = organization
        @config = config || {}
      end

      attr_reader :organization, :config

      # TODO: merge from config
      def categories
        @categories ||= decidim_defaults.deep_merge(config)
      end

      # Categories coming from the Decidim defaults (or initializers) can only be edited partially
      # - title and description can be edited
      # - slug, mandatory, visibility and items are not editable
      def decidim_defaults
        (Decidim.consent_categories || []).to_h do |category|
          slug = category[:slug].to_s
          [
            slug,
            {
              "slug" => slug,
              "default" => true,
              "editable" => !category[:mandatory],
              "mandatory" => category[:mandatory] || false,
              "visibility" => "visible",
              "title" => localized_translation("layouts.decidim.data_consent.modal.#{slug}.title"),
              "description" => localized_translation("layouts.decidim.data_consent.modal.#{slug}.description"),
              "items" => (category[:items] || []).to_h do |item|
                name = item[:name].to_s
                [
                  name,
                  {
                    "name" => name,
                    "type" => item[:type].to_s,
                    "service" => localized_translation("layouts.decidim.data_consent.details.items.#{name}.service"),
                    "description" => localized_translation("layouts.decidim.data_consent.details.items.#{name}.description"),
                    "expiration" => localized_translation("layouts.decidim.data_consent.details.items.#{name}.expiration")
                  }
                ]
              end
            }
          ]
        end
      end

      def localized_translation(key)
        organization.available_locales.each_with_object({}) do |locale, hash|
          hash[locale.to_s] = I18n.t(key, locale: locale, default: "")
        end
      end
    end
  end
end
