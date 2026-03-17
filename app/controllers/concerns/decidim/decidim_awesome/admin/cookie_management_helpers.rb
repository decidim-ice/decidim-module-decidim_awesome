# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      module CookieManagementHelpers
        private

        def store
          @store ||= CookieManagementStore.new(current_organization, awesome_consent_categories)
        end

        def awesome_consent_categories
          Decidim::DecidimAwesome::AwesomeConfig.find_by(organization: current_organization, var: :cookie_management)&.value
        end

        def category_title_for_breadcrumb(slug)
          category = store.categories[slug]
          return slug unless category

          translated_attribute(category["title"]) || slug
        end

        def add_breadcrumb_item(key, url = nil)
          controller_breadcrumb_items << {
            label: translate_breadcrumb(key),
            url: url,
            active: url.blank?
          }
        end

        def translate_breadcrumb(key)
          return key unless key.is_a?(Symbol)

          I18n.t(key, scope: "decidim.decidim_awesome.admin.breadcrumb", default: key.to_s.humanize)
        end
      end
    end
  end
end
