# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      # Editing menu items
      class MenuHacksController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig
        helper ConfigConstraintsHelpers

        layout "decidim/admin/decidim_awesome"

        helper_method :current_items, :md5, :visibility_options, :target_options

        before_action do
          enforce_permission_to :edit_config, :menu
        end

        def new
          @form = form(MenuForm).instance
        end

        def create
          @form = form(MenuForm).from_params(params)
          CreateMenuHack.call(@form, current_menu_name) do
            on(:ok) do
              flash[:notice] = I18n.t("menu_hacks.create.success", scope: "decidim.decidim_awesome.admin")
              redirect_to decidim_admin_decidim_awesome.menu_hacks_path
            end

            on(:invalid) do |message|
              flash.now[:alert] = I18n.t("menu_hacks.create.error", error: message, scope: "decidim.decidim_awesome.admin")
              render :new
            end
          end
        end

        def edit
          @form = form(MenuForm).from_model(menu_item)
        end

        def update
          @form = form(MenuForm).from_params(params)
          UpdateMenuHack.call(@form, current_menu_name) do
            on(:ok) do
              flash[:notice] = I18n.t("menu_hacks.update.success", scope: "decidim.decidim_awesome.admin")
              redirect_to decidim_admin_decidim_awesome.menu_hacks_path
            end

            on(:invalid) do |message|
              flash.now[:alert] = I18n.t("menu_hacks.update.error", error: message, scope: "decidim.decidim_awesome.admin")
              render :edit
            end
          end
        end

        # TODO: destroy

        private

        def menu_item
          item = current_items.find { |i| md5(i.url) == params[:id] }
          OpenStruct.new(
            raw_label: item.try(:raw_label) || { current_organization.default_locale => item.label },
            url: item.url,
            position: item.position,
            target: item.try(:target),
            visibility: item.try(:visibility)
          )
        end

        def current_items
          @current_items ||= current_menu.items(true)
        end

        def current_menu
          @current_menu ||= MenuHacker.new(current_menu_name, self)
        end

        def current_menu_name
          :menu
        end

        def md5(text)
          Digest::MD5.hexdigest(text)
        end

        def visibility_options
          [:default, :hidden]
        end

        def target_options
          ["", :_blank]
        end
      end
    end
  end
end
