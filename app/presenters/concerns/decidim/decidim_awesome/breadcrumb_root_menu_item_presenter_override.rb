# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module BreadcrumbRootMenuItemPresenterOverride
      extend ActiveSupport::Concern

      included do
        def arrow_link(text, url, args = {})
          link_to url, extended_html_options.merge(class: args.with_indifferent_access[:class]) do
            "<span>#{text}</span> #{icon("arrow-right-line")}".html_safe
          end
        end

        def extended_html_options
          {}.tap do |opts|
            opts[:target] = "_blank" if @menu_item.try(:target) == "_blank"
          end
        end
      end
    end
  end
end
