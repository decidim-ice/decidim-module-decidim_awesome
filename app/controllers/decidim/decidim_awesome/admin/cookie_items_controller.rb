# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CookieItemsController < DecidimAwesome::Admin::ApplicationController
        include CookieManagementHelpers
        helper ConfigConstraintsHelpers

        helper_method :category_items, :item, :cookie_item_presets, :category

        before_action :set_cookie_items_breadcrumb
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
          @form = form(CookieItemForm).from_params(item)
        end

        def create
          @form = form(CookieItemForm).from_params(params, category_items:)

          UpdateCookieItem.call(@form, params[:cookie_category_slug]) do
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

        def create_preset
          items = preset_builder.find(params[:preset_name])
          unless items
            return redirect_to(decidim_admin_decidim_awesome.cookie_category_cookie_items_path(params[:cookie_category_slug]),
                               alert: I18n.t("cookie_items.create_preset.not_found", scope: "decidim.decidim_awesome.admin"))
          end

          @forms = preset_builder.build_forms(items)

          CreateCookieItemPreset.call(@forms, params[:cookie_category_slug]) do
            on(:ok) do
              flash[:notice] = I18n.t("cookie_items.create_preset.success", scope: "decidim.decidim_awesome.admin")
              redirect_to decidim_admin_decidim_awesome.cookie_category_cookie_items_path(params[:cookie_category_slug])
            end

            on(:invalid) do |error_message|
              flash[:alert] = I18n.t("cookie_items.create_preset.error", scope: "decidim.decidim_awesome.admin", error: error_message)
              redirect_to decidim_admin_decidim_awesome.cookie_category_cookie_items_path(params[:cookie_category_slug])
            end
          end
        end

        def update
          @form = form(CookieItemForm).from_params(params, category_items:, current_name: params[:name])

          UpdateCookieItem.call(@form, params[:cookie_category_slug]) do
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
          store.categories[params[:cookie_category_slug]] || raise(ActiveRecord::RecordNotFound)
        end

        def category_items
          category&.dig("items") || {}
        end

        def item
          category_items[params[:name]] || raise(ActiveRecord::RecordNotFound)
        end

        def set_cookie_items_breadcrumb
          add_breadcrumb_item :cookie_management, decidim_admin_decidim_awesome.cookie_categories_path
        end

        def preset_builder
          @preset_builder ||= CookieItemPresetBuilder.new(form(CookieItemForm), current_organization)
        end

        def cookie_item_presets
          preset_builder.presets
        end
      end
    end
  end
end
