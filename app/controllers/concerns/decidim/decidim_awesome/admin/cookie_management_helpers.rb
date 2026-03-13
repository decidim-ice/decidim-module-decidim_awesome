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
          @store ||= CookieManagementStore.new(current_organization, awesome_categories)
        end

        def awesome_categories
          Decidim::DecidimAwesome::AwesomeConfig.find_by(organization: current_organization, var: :cookie_management)&.value
        end

        def visibility_options
          CookieCategoryForm::VISIBILITY_STATES.index_by do |key|
            I18n.t(".cookie_categories.form.visibility.#{key}", scope: "decidim.decidim_awesome.admin")
          end
        end

        def find_category!(slug)
          store.find_category(slug) || raise(ActiveRecord::RecordNotFound)
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
