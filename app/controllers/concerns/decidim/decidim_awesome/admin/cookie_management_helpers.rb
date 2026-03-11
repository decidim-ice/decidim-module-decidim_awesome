# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      module CookieManagementHelpers
        extend ActiveSupport::Concern

        included do
          include NeedsAwesomeConfig
          include ConfigConstraintsHelpers
          include CookieBreadcrumbHelper

          helper ConfigConstraintsHelpers
        end

        private

        def store
          @store ||= CookieManagementStore.new(current_organization)
        end

        def visibility_options
          CookieCategoryForm::VISIBILITY_STATES.index_by do |key|
            I18n.t(".cookie_categories.form.visibility.#{key}", scope: "decidim.decidim_awesome.admin")
          end
        end

        def category_for_form(slug)
          category = store.find_category(slug)
          raise ActiveRecord::RecordNotFound unless category

          {
            slug: category.slug,
            mandatory: category.mandatory?,
            title: category.title,
            description: category.description,
            visibility: category.visibility
          }
        end

        def current_category_title(slug)
          category = store.find_category(slug)
          return slug unless category

          translated_attribute(category.title) || slug
        end

        def category_from_params
          category = store.find_category(params[:cookie_category_slug])
          raise ActiveRecord::RecordNotFound unless category

          category
        end

        def item_for_form(category_slug, item_name)
          category = store.find_category(category_slug)
          raise ActiveRecord::RecordNotFound unless category

          items = category.items
          item = items.find { |i| i.name.to_s == item_name.to_s }
          raise ActiveRecord::RecordNotFound unless item

          {
            name: item.name,
            type: item.type,
            service: item.service,
            description: item.description
          }
        end

        def item_type_options
          CookieItemForm::ITEM_TYPES.index_by do |type|
            I18n.t("cookie_item.types.#{type}", scope: "activemodel.attributes")
          end
        end

        def category_title_for_breadcrumb(slug)
          category = store.find_category(slug)
          return slug unless category

          translated_attribute(category.title) || slug
        end
      end
    end
  end
end
