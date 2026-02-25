# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CookieCategoriesController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig
        include Admin::ConfigConstraintsHelpers
        include HasCookieCategories

        helper Admin::ConfigConstraintsHelpers
        helper_method :current_categories

        before_action do
          enforce_permission_to :edit_config, :cookie_management
        end

        def index
          ensure_categories_initialized!
        end

        def new
          @form = form(CookieCategoryForm).instance
        end

        def edit
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

        def cookie_management_setting
          @cookie_management_setting ||= AwesomeConfig.find_or_initialize_by(var: :cookie_management, organization: current_organization)
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

        def ensure_categories_initialized!
          return unless categories_data["categories"].empty?

          initialize_default_categories!
        end

        def initialize_default_categories!
          default_categories = default_decidim_categories
          save_categories!(default_categories)
          default_categories
        end

        def save_categories!(categories)
          cookie_management_setting.value = { "categories" => categories }
          cookie_management_setting.save!
          @categories_data = nil
        end

        def category_for_form
          category = current_categories.find { |c| c["slug"].to_s == params[:slug].to_s }
          raise ActiveRecord::RecordNotFound unless category

          {
            slug: category["slug"],
            mandatory: category["mandatory"],
            title: category["title"],
            description: category["description"]
          }
        end
      end
    end
  end
end
