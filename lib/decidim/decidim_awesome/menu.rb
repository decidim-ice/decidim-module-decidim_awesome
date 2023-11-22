# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class Menu
      def self.register_awesome_admin_menu!
        Decidim.menu :awesome_admin_menu do |menu|
          menu.add_item :editors,
                        I18n.t("menu.editors", scope: "decidim.decidim_awesome.admin"),
                        decidim_admin_decidim_awesome.config_path(:editors),
                        position: 1,
                        icon_name: "editors-text",
                        if: menus[:editors]

          menu.add_item :proposals,
                        I18n.t("menu.proposals", scope: "decidim.decidim_awesome.admin"),
                        decidim_admin_decidim_awesome.config_path(:proposals),
                        position: 2,
                        icon_name: "documents",
                        if: menus[:proposals]

          menu.add_item :surveys,
                        I18n.t("menu.surveys", scope: "decidim.decidim_awesome.admin"),
                        decidim_admin_decidim_awesome.config_path(:surveys),
                        position: 3,
                        icon_name: "surveys",
                        if: menus[:surveys]

          menu.add_item :styles,
                        I18n.t("menu.styles", scope: "decidim.decidim_awesome.admin"),
                        decidim_admin_decidim_awesome.config_path(:styles),
                        position: 4,
                        icon_name: "brush",
                        if: menus[:styles]

          menu.add_item :proposal_custom_fields,
                        I18n.t("menu.proposal_custom_fields", scope: "decidim.decidim_awesome.admin"),
                        decidim_admin_decidim_awesome.config_path(:proposal_custom_fields),
                        position: 5,
                        icon_name: "layers",
                        if: menus[:proposal_custom_fields]

          menu.add_item :admins,
                        I18n.t("menu.admins", scope: "decidim.decidim_awesome.admin"),
                        decidim_admin_decidim_awesome.config_path(:admins),
                        position: 6,
                        icon_name: "group-line",
                        if: menus[:admins]

          menu.add_item :menu_hacks,
                        I18n.t("menu.menu_hacks", scope: "decidim.decidim_awesome.admin"),
                        decidim_admin_decidim_awesome.menu_hacks_path,
                        position: 7,
                        icon_name: "menu-line",
                        if: menus[:menu_hacks]

          menu.add_item :custom_redirects,
                        I18n.t("menu.custom_redirects", scope: "decidim.decidim_awesome.admin"),
                        decidim_admin_decidim_awesome.custom_redirects_path,
                        position: 8,
                        icon_name: "external-link-line",
                        if: menus[:custom_redirects]

          menu.add_item :livechat,
                        I18n.t("menu.livechat", scope: "decidim.decidim_awesome.admin"),
                        decidim_admin_decidim_awesome.config_path(:livechat),
                        position: 9,
                        icon_name: "chat-1-line",
                        if: menus[:livechat]

          menu.add_item :checks,
                        I18n.t("menu.checks", scope: "decidim.decidim_awesome.admin"),
                        decidim_admin_decidim_awesome.checks_path,
                        position: 10,
                        icon_name: "pulse"
        end
      end

      def self.menus
        @menus ||= {
          editors: config_enabled?([:allow_images_in_full_editor, :allow_images_in_small_editor, :use_markdown_editor, :allow_images_in_markdown_editor]),
          proposals: config_enabled?(
            [
              :allow_images_in_proposals,
              :validate_title_min_length, :validate_title_max_caps_percent,
              :validate_title_max_marks_together, :validate_title_start_with_caps,
              :validate_body_min_length, :validate_body_max_caps_percent,
              :validate_body_max_marks_together, :validate_body_start_with_caps
            ]
          ),
          surveys: config_enabled?(:auto_save_forms),
          styles: config_enabled?(:scoped_styles),
          proposal_custom_fields: config_enabled?(:proposal_custom_fields),
          admins: config_enabled?(:scoped_admins),
          menu_hacks: config_enabled?(:menu),
          custom_redirects: config_enabled?(:custom_redirects),
          livechat: config_enabled?([:intergram_for_admins, :intergram_for_public])
        }
      end

      # ensure boolean value
      def self.config_enabled?(var)
        DecidimAwesome.enabled?(var)
      end
    end
  end
end
