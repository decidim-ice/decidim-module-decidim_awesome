# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      module CookieManagementHelpers
        extend ActiveSupport::Concern

        included do
          include NeedsAwesomeConfig
          include ConfigConstraintsHelpers
          include HasCookieCategories
          include CookieBreadcrumbHelper

          helper ConfigConstraintsHelpers
        end

        private

        def cookie_management_setting
          @cookie_management_setting ||= AwesomeConfig.find_or_initialize_by(
            var: :cookie_management,
            organization: current_organization
          )
        end

        def categories_data
          @categories_data ||= begin
            data = cookie_management_setting.value
            data = {} unless data.is_a?(Hash)
            data["categories"] = [] unless data["categories"].is_a?(Array)
            data
          end
        end

        def current_categories
          categories_data["categories"]
        end

        def save_categories!(categories)
          cookie_management_setting.value = { "categories" => categories }
          cookie_management_setting.save!
        end

        def visibility_options
          MenuForm::VISIBILITY_STATES.index_by do |key|
            I18n.t(".menu_hacks.form.visibility.#{key}", scope: "decidim.decidim_awesome.admin")
          end
        end

        def ensure_categories_initialized!
          return unless categories_data["categories"].empty?

          initialize_default_categories!
        end

        def initialize_default_categories!
          default_categories = default_decidim_categories
          save_categories!(default_categories)
          default_categories
        end

        def find_category(slug)
          current_categories.find { |c| c["slug"].to_s == slug.to_s }
        end

        def category_for_form(slug)
          category = find_category(slug)
          raise ActiveRecord::RecordNotFound unless category

          {
            slug: category["slug"],
            mandatory: category["mandatory"],
            title: category["title"],
            description: category["description"],
            visibility: category["visibility"]
          }
        end

        def current_category_title(slug)
          category = find_category(slug)
          return slug unless category

          translated_attribute(category["title"]) || slug
        end

        def category_from_params
          find_category(params[:cookie_category_slug])
        end

        def item_for_form(category_slug, item_name)
          category = find_category(category_slug)
          raise ActiveRecord::RecordNotFound unless category

          items = category["items"].is_a?(Array) ? category["items"] : []
          item = items.find { |i| i["name"].to_s == item_name.to_s }
          raise ActiveRecord::RecordNotFound unless item

          {
            name: item["name"],
            type: item["type"],
            service: item["service"],
            description: item["description"]
          }
        end

        def item_type_options
          CookieItemForm::ITEM_TYPES.index_by do |type|
            I18n.t("cookie_item.types.#{type}", scope: "activemodel.attributes")
          end
        end

        def category_title_for_breadcrumb(slug)
          category = find_category(slug)
          return slug unless category

          translated_attribute(category["title"]) || slug
        end

        def prevent_mandatory_category_edit
          category = find_category(params[:slug])
          return unless category
          return unless default_category?(params[:slug])
          return unless category["mandatory"]

          flash[:alert] = I18n.t("cookie_categories.edit.cannot_edit_mandatory", scope: "decidim.decidim_awesome.admin")
          redirect_to decidim_admin_decidim_awesome.cookie_categories_path
        end

        def prevent_mandatory_category_items_edit
          category = category_from_params
          return unless category
          return unless default_category?(params[:cookie_category_slug])
          return unless category["mandatory"]

          flash[:alert] = I18n.t("cookie_items.edit.cannot_edit_mandatory_category", scope: "decidim.decidim_awesome.admin")
          redirect_to decidim_admin_decidim_awesome.cookie_category_cookie_items_path(params[:cookie_category_slug])
        end
      end
    end
  end
end
