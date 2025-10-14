# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module MenuItemPresenterOverride
      extend ActiveSupport::Concern

      included do
        def link_to(name = nil, options = nil, html_options = nil, &)
          html_options ||= {}
          html_options[:target] = @menu_item.try(:target)

          options ||= html_options
          @view.link_to(name, options, html_options, &)
        end

        def active
          return @menu_item.active.call(url, @view) if @menu_item.try(:active).respond_to?(:call)

          @menu_item&.active
        end

        def active_for_breadcrumb?
          is_active_link?(url, @menu_item.try(:original_active) || active)
        end

        def hacked_not_overriding?
          !(@menu_item.is_a?(Decidim::MenuItem) || @menu_item.overridden?)
        end
      end
    end
  end
end
