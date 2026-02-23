# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CookieCategoriesController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig
        include ConfigConstraintsHelpers

        helper ConfigConstraintsHelpers
        helper_method :current_categories

        before_action do
          enforce_permission_to :edit_config, :cookie_management
        end

        def index; end

        def new
          @form = form(CookieCategoryForm).instance
        end

        def edit
          @form = form(CookieCategoryForm).from_params(category_for_form)
        end

        def create
          @form = form(CookieCategoryForm).from_params(params)
          return render(:new) if @form.invalid?

          categories = current_categories
          if categories.any? { |c| c["slug"].to_s == @form.slug }
            flash.now[:alert] = I18n.t("cookie_categories.create.error", scope: "decidim.decidim_awesome.admin", error: "Slug already exists")
            return render :new
          end

          categories << @form.to_params
          save_categories!(categories)

          flash[:notice] = I18n.t("cookie_categories.create.success", scope: "decidim.decidim_awesome.admin")
          redirect_to decidim_admin_decidim_awesome.cookie_categories_path
        rescue ActiveRecord::RecordInvalid => e
          details = e.record.errors.full_messages.join(", ")
          details = e.message if details.blank?
          flash.now[:alert] = I18n.t("cookie_categories.create.error", scope: "decidim.decidim_awesome.admin", error: details)
          render :new
        rescue StandardError => e
          details = [e.class.name, e.message.presence].compact.join(": ")
          flash.now[:alert] = I18n.t("cookie_categories.create.error", scope: "decidim.decidim_awesome.admin", error: details)
          render :new
        end

        def update
          @form = form(CookieCategoryForm).from_params(params)
          return render(:edit) if @form.invalid?

          categories = current_categories
          idx = categories.index { |c| c["slug"].to_s == params[:slug].to_s }
          raise ActiveRecord::RecordNotFound if idx.nil?

          items = categories[idx]["items"].is_a?(Array) ? categories[idx]["items"] : []
          updated = @form.to_params
          updated["items"] = items

          categories[idx] = updated
          save_categories!(categories)

          flash[:notice] = I18n.t("cookie_categories.update.success", scope: "decidim.decidim_awesome.admin")
          redirect_to decidim_admin_decidim_awesome.cookie_categories_path
        end

        def destroy
          categories = current_categories
          categories.reject! { |c| c["slug"].to_s == params[:slug].to_s }
          save_categories!(categories)

          flash[:notice] = I18n.t("cookie_categories.destroy.success", scope: "decidim.decidim_awesome.admin")
          redirect_to decidim_admin_decidim_awesome.cookie_categories_path
        end

        private

        def cookie_management_setting
          AwesomeConfig.find_or_initialize_by(var: :cookie_management, organization: current_organization)
        end

        def current_categories
          raw = cookie_management_setting.value
          return [] unless raw.is_a?(Hash) && raw["categories"].is_a?(Array)

          raw["categories"]
        end

        def save_categories!(categories)
          setting = cookie_management_setting
          setting.value = { "categories" => categories }
          setting.save!
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
