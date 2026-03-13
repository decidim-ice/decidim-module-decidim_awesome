# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      module CookieBreadcrumbHelper
        extend ActiveSupport::Concern

        private

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
