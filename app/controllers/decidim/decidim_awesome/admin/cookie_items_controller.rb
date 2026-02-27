# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CookieItemsController < DecidimAwesome::Admin::ApplicationController
        include CookieManagementHelpers

        helper_method :category, :default_category?, :default_cookie_item?, :cookie_item_modified?, :item_type_options

        before_action :set_cookie_items_breadcrumb
        before_action :prevent_mandatory_category_items_edit, only: [:edit, :update, :destroy]
        before_action do
          enforce_permission_to :edit_config, :cookie_management
        end

        def index; end

        def new
          add_breadcrumb_item :new, decidim_admin_decidim_awesome.cookie_category_cookie_items_path(params[:cookie_category_slug])
          @form = form(CookieItemForm).instance
        end

        def edit
          add_breadcrumb_item :edit, decidim_admin_decidim_awesome.cookie_category_cookie_items_path(params[:cookie_category_slug])
          @form = form(CookieItemForm).from_params(item_for_form)
        end

        def create
          @form = form(CookieItemForm).from_params(params)

          CreateCookieItem.call(@form, params[:cookie_category_slug]) do
            on(:ok) do
              flash[:notice] = I18n.t("cookie_items.create.success", scope: "decidim.decidim_awesome.admin")
              redirect_to decidim_admin_decidim_awesome.cookie_category_cookie_items_path(params[:cookie_category_slug])
            end

            on(:invalid) do |error_message|
              error = error_message.presence || @form.errors.full_messages.join(", ")
              flash.now[:alert] = I18n.t("cookie_items.create.error", scope: "decidim.decidim_awesome.admin", error: error)
              render :new
            end
          end
        end

        def update
          @form = form(CookieItemForm).from_params(params)

          UpdateCookieItem.call(@form, params[:cookie_category_slug], params[:name]) do
            on(:ok) do
              flash[:notice] = I18n.t("cookie_items.update.success", scope: "decidim.decidim_awesome.admin")
              redirect_to decidim_admin_decidim_awesome.cookie_category_cookie_items_path(params[:cookie_category_slug])
            end

            on(:invalid) do |error_message|
              error = error_message.presence || @form.errors.full_messages.join(", ")
              flash.now[:alert] = I18n.t("cookie_items.update.error", scope: "decidim.decidim_awesome.admin", error: error)
              render :edit
            end
          end
        end

        def destroy
          DestroyCookieItem.call(params[:cookie_category_slug], params[:name], current_organization) do
            on(:ok) do
              flash[:notice] = I18n.t("cookie_items.destroy.success", scope: "decidim.decidim_awesome.admin")
              redirect_to decidim_admin_decidim_awesome.cookie_category_cookie_items_path(params[:cookie_category_slug])
            end

            on(:invalid) do |error_message|
              flash[:alert] = I18n.t("cookie_items.destroy.error", scope: "decidim.decidim_awesome.admin", error: error_message)
              redirect_to decidim_admin_decidim_awesome.cookie_category_cookie_items_path(params[:cookie_category_slug])
            end
          end
        end

        private

        def category
          current_categories.find { |c| c["slug"].to_s == params[:cookie_category_slug].to_s }
        end

        def item_for_form
          raise ActiveRecord::RecordNotFound unless category

          items = category["items"].is_a?(Array) ? category["items"] : []
          item = items.find { |i| i["name"].to_s == params[:name].to_s }
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

        def category_title
          return params[:cookie_category_slug] unless category

          translated_attribute(category["title"]) || params[:cookie_category_slug]
        end

        def set_cookie_items_breadcrumb
          add_breadcrumb_item :cookie_management, decidim_admin_decidim_awesome.cookie_categories_path
          add_breadcrumb_item category_title, decidim_admin_decidim_awesome.cookie_category_cookie_items_path(params[:cookie_category_slug])
        end

        def prevent_mandatory_category_items_edit
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
