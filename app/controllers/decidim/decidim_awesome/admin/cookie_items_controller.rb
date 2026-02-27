# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CookieItemsController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig
        include ConfigConstraintsHelpers
        include HasCookieCategories

        helper ConfigConstraintsHelpers
        helper_method :category, :default_cookie_item?, :cookie_item_modified?, :item_type_options

        before_action do
          enforce_permission_to :edit_config, :cookie_management
        end

        def index; end

        def new
          @form = form(CookieItemForm).instance
        end

        def edit
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

        def category
          current_categories.find { |c| c["slug"].to_s == params[:cookie_category_slug].to_s }
        end

        def item_for_form
          cat = category
          raise ActiveRecord::RecordNotFound unless cat

          items = cat["items"].is_a?(Array) ? cat["items"] : []
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
      end
    end
  end
end
