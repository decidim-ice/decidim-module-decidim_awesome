# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CookieCategoriesController < DecidimAwesome::Admin::ApplicationController
        include CookieManagementHelpers

        helper_method :current_categories, :visibility_options, :default_category?, :category_modified?

        before_action :set_cookie_management_breadcrumb
        before_action :prevent_mandatory_category_edit, only: [:edit, :update]
        before_action do
          enforce_permission_to :edit_config, :cookie_management
        end

        def index
          ensure_categories_initialized!
        end

        def new
          add_breadcrumb_item :new, decidim_admin_decidim_awesome.cookie_categories_path
          @form = form(CookieCategoryForm).instance
        end

        def edit
          add_breadcrumb_item current_category_title, decidim_admin_decidim_awesome.cookie_categories_path
          @form = form(CookieCategoryForm).from_params(category_for_form)
        end

        def create
          @form = form(CookieCategoryForm).from_params(params)

          CreateCookieCategory.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("cookie_categories.create.success", scope: "decidim.decidim_awesome.admin")
              redirect_to decidim_admin_decidim_awesome.cookie_categories_path
            end

            on(:invalid) do |error_message|
              error = error_message.presence || @form.errors.full_messages.join(", ")
              flash.now[:alert] = I18n.t("cookie_categories.create.error", scope: "decidim.decidim_awesome.admin", error: error)
              render :new
            end
          end
        end

        def update
          @form = form(CookieCategoryForm).from_params(params)

          UpdateCookieCategory.call(@form, params[:slug]) do
            on(:ok) do
              flash[:notice] = I18n.t("cookie_categories.update.success", scope: "decidim.decidim_awesome.admin")
              redirect_to decidim_admin_decidim_awesome.cookie_categories_path
            end

            on(:invalid) do |error_message|
              error = error_message.presence || @form.errors.full_messages.join(", ")
              flash.now[:alert] = I18n.t("cookie_categories.update.error", scope: "decidim.decidim_awesome.admin", error: error)
              render :edit
            end
          end
        end

        def destroy
          DestroyCookieCategory.call(params[:slug], current_organization) do
            on(:ok) do
              flash[:notice] = I18n.t("cookie_categories.destroy.success", scope: "decidim.decidim_awesome.admin")
              redirect_to decidim_admin_decidim_awesome.cookie_categories_path
            end

            on(:invalid) do |error_message|
              flash[:alert] = I18n.t("cookie_categories.destroy.error", scope: "decidim.decidim_awesome.admin", error: error_message)
              redirect_to decidim_admin_decidim_awesome.cookie_categories_path
            end
          end
        end

        private

        def ensure_categories_initialized!
          return unless categories_data["categories"].empty?

          initialize_default_categories!
        end

        def initialize_default_categories!
          default_categories = default_decidim_categories
          save_categories!(default_categories)
          default_categories
        end

        def category_for_form
          category = current_categories.find { |c| c["slug"].to_s == params[:slug].to_s }
          raise ActiveRecord::RecordNotFound unless category

          {
            slug: category["slug"],
            mandatory: category["mandatory"],
            title: category["title"],
            description: category["description"],
            visibility: category["visibility"]
          }
        end

        def current_category_title
          category = current_categories.find { |c| c["slug"].to_s == params[:slug].to_s }
          return params[:slug] unless category

          translated_attribute(category["title"]) || params[:slug]
        end

        def set_cookie_management_breadcrumb
          add_breadcrumb_item :cookie_management, decidim_admin_decidim_awesome.cookie_categories_path
        end

        def prevent_mandatory_category_edit
          category = current_categories.find { |c| c["slug"].to_s == params[:slug].to_s }
          return unless category
          return unless default_category?(params[:slug])
          return unless category["mandatory"]

          flash[:alert] = I18n.t("cookie_categories.edit.cannot_edit_mandatory", scope: "decidim.decidim_awesome.admin")
          redirect_to decidim_admin_decidim_awesome.cookie_categories_path
        end
      end
    end
  end
end
