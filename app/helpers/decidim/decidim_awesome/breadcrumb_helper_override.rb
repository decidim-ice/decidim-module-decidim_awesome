# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module BreadcrumbHelperOverride
      extend ActiveSupport::Concern

      included do
        def active_breadcrumb_item(target_menu)
          active_item = ::Decidim::MenuPresenter.new(target_menu, self).active_item_for_breadcrumb

          return if active_item.blank?

          {
            label: active_item.label,
            url: active_item.url,
            active: active_item.active?
          }
        end
      end
    end
  end
end
