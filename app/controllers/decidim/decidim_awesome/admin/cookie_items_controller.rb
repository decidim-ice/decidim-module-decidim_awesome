# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CookieItemsController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig
        include ConfigConstraintsHelpers

        helper ConfigConstraintsHelpers
        helper_method :category

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
          return render(:new) if @form.invalid?

          data = cookie_management_setting.value
          data = {} unless data.is_a?(Hash)
          data["categories"] = [] unless data["categories"].is_a?(Array)

          cat = data["categories"].find { |c| c["slug"].to_s == params[:cookie_category_slug].to_s }
          raise ActiveRecord::RecordNotFound unless cat

          cat["items"] = [] unless cat["items"].is_a?(Array)
          if cat["items"].any? { |i| i["name"].to_s == @form.name }
            flash.now[:alert] = I18n.t("cookie_items.create.error", scope: "decidim.decidim_awesome.admin")
            return render :new
          end

          cat["items"] << @form.to_params
          cookie_management_setting.value = data
          cookie_management_setting.save!

          flash[:notice] = I18n.t("cookie_items.create.success", scope: "decidim.decidim_awesome.admin")
          redirect_to decidim_admin_decidim_awesome.cookie_category_cookie_items_path(params[:cookie_category_slug])
        end

        def update
          @form = form(CookieItemForm).from_params(params)
          return render(:edit) if @form.invalid?

          data = cookie_management_setting.value
          data = {} unless data.is_a?(Hash)
          cat = data["categories"].find { |c| c["slug"].to_s == params[:cookie_category_slug].to_s }
          raise ActiveRecord::RecordNotFound unless cat

          cat["items"] = [] unless cat["items"].is_a?(Array)
          idx = cat["items"].index { |i| i["name"].to_s == params[:name].to_s }
          raise ActiveRecord::RecordNotFound if idx.nil?

          cat["items"][idx] = @form.to_params
          cookie_management_setting.value = data
          cookie_management_setting.save!

          flash[:notice] = I18n.t("cookie_items.update.success", scope: "decidim.decidim_awesome.admin")
          redirect_to decidim_admin_decidim_awesome.cookie_category_cookie_items_path(params[:cookie_category_slug])
        end

        def destroy
          data = cookie_management_setting.value
          data = {} unless data.is_a?(Hash)
          cat = data["categories"].find { |c| c["slug"].to_s == params[:cookie_category_slug].to_s }
          raise ActiveRecord::RecordNotFound unless cat

          cat["items"] = [] unless cat["items"].is_a?(Array)
          cat["items"].reject! { |i| i["name"].to_s == params[:name].to_s }

          cookie_management_setting.value = data
          cookie_management_setting.save!

          flash[:notice] = I18n.t("cookie_items.destroy.success", scope: "decidim.decidim_awesome.admin")
          redirect_to decidim_admin_decidim_awesome.cookie_category_cookie_items_path(params[:cookie_category_slug])
        end

        private

        def cookie_management_setting
          @cookie_management_setting ||= AwesomeConfig.find_or_initialize_by(var: :cookie_management, organization: current_organization)
        end

        def category
          raw = cookie_management_setting.value
          categories = raw.is_a?(Hash) ? raw["categories"] : nil
          categories = [] unless categories.is_a?(Array)
          categories.find { |c| c["slug"].to_s == params[:cookie_category_slug].to_s }
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
      end
    end
  end
end
