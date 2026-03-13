# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CookieCategoriesController < DecidimAwesome::Admin::ApplicationController
        include CookieManagementHelpers

        helper_method :categories, :visibility_options

        before_action :set_cookie_management_breadcrumb
        before_action do
          enforce_permission_to :edit_config, :cookie_management
        end

        def index; end

        def new
          add_breadcrumb_item :new, decidim_admin_decidim_awesome.cookie_categories_path
          @form = form(CookieCategoryForm).instance
        end

        def edit
          add_breadcrumb_item category_title_for_breadcrumb(params[:slug]), decidim_admin_decidim_awesome.cookie_categories_path
          category = find_category!(params[:slug])
          @form = form(CookieCategoryForm).from_params(category.to_form_params)
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

        def categories
          store.categories
        end

        def set_cookie_management_breadcrumb
          add_breadcrumb_item :cookie_management, decidim_admin_decidim_awesome.cookie_categories_path
        end
      end
    end
  end
end
