# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class Menu
      class << self
        def register_awesome_admin_menu!
          Decidim.menu :awesome_admin_menu do |menu|
            if menus[:editors].present?
              menu.add_item :editors,
                            I18n.t("menu.editors", scope: "decidim.decidim_awesome.admin"),
                            decidim_admin_decidim_awesome.config_path(:editors),
                            position: 1,
                            icon_name: "editors-text"
            end

            if menus[:proposals].present?
              menu.add_item :proposals,
                            I18n.t("menu.proposals", scope: "decidim.decidim_awesome.admin"),
                            decidim_admin_decidim_awesome.config_path(:proposals),
                            position: 2,
                            icon_name: "documents"
            end

            if menus[:surveys].present?
              menu.add_item :surveys,
                            I18n.t("menu.surveys", scope: "decidim.decidim_awesome.admin"),
                            decidim_admin_decidim_awesome.config_path(:surveys),
                            position: 3,
                            icon_name: "surveys"
            end

            if menus[:styles].present?
              menu.add_item :styles,
                            I18n.t("menu.styles", scope: "decidim.decidim_awesome.admin"),
                            decidim_admin_decidim_awesome.config_path(menus[:styles]),
                            position: 4,
                            icon_name: "brush",
                            submenu: { target_menu: :custom_styles_submenu }
            end

            if menus[:custom_fields].present?
              menu.add_item :custom_fields,
                            I18n.t("menu.proposal_custom_fields", scope: "decidim.decidim_awesome.admin"),
                            decidim_admin_decidim_awesome.config_path(menus[:custom_fields]),
                            position: 5,
                            icon_name: "layers",
                            active: is_active_link?(decidim_admin_decidim_awesome.config_path(:proposal_custom_fields)) ||
                                    is_active_link?(decidim_admin_decidim_awesome.config_path(:proposal_private_custom_fields)),
                            submenu: { target_menu: :custom_fields_submenu }
            end

            if menus[:admins].present?
              menu.add_item :admins,
                            I18n.t("menu.admins", scope: "decidim.decidim_awesome.admin"),
                            decidim_admin_decidim_awesome.config_path(:admins),
                            position: 6,
                            icon_name: "group-line"
            end

            if menus[:menu_hacks].present?
              menu.add_item :menu_hacks,
                            I18n.t("menu.menu_hacks", scope: "decidim.decidim_awesome.admin"),
                            decidim_admin_decidim_awesome.menu_hacks_path(menus[:menu_hacks]),
                            position: 7,
                            icon_name: "menu-line",
                            active: is_active_link?(decidim_admin_decidim_awesome.menu_hacks_path(:menu)) ||
                                    is_active_link?(decidim_admin_decidim_awesome.menu_hacks_path(:mobile_menu)) ||
                                    is_active_link?(decidim_admin_decidim_awesome.menu_hacks_path(:home_content_block_menu)),
                            submenu: { target_menu: :menu_hacks_submenu }
            end

            if menus[:custom_redirects].present?
              menu.add_item :custom_redirects,
                            I18n.t("menu.custom_redirects", scope: "decidim.decidim_awesome.admin"),
                            decidim_admin_decidim_awesome.custom_redirects_path,
                            position: 8,
                            icon_name: "external-link-line"
            end

            if menus[:livechat].present?
              menu.add_item :livechat,
                            I18n.t("menu.livechat", scope: "decidim.decidim_awesome.admin"),
                            decidim_admin_decidim_awesome.config_path(:livechat),
                            position: 9,
                            icon_name: "chat-1-line"
            end

            if menus[:verifications].present?
              menu.add_item :verifications,
                            I18n.t("menu.verifications", scope: "decidim.decidim_awesome.admin"),
                            decidim_admin_decidim_awesome.config_path(:verifications),
                            position: 10,
                            icon_name: "fingerprint-line"
            end

            menu.add_item :maintenance,
                          I18n.t("maintenance", scope: "decidim.decidim_awesome.admin.menu.maintenance"),
                          decidim_admin_decidim_awesome.private_data_path,
                          position: 11,
                          icon_name: "tools-line",
                          active: is_active_link?(decidim_admin_decidim_awesome.private_data_path) ||
                                  is_active_link?(decidim_admin_decidim_awesome.hashcashes_path) ||
                                  is_active_link?(decidim_admin_decidim_awesome.checks_path),
                          submenu: { target_menu: :maintenance_submenu }
          end
        end

        def register_custom_fields_submenu!
          Decidim.menu :custom_fields_submenu do |menu|
            if menus[:proposal_custom_fields].present?
              menu.add_item :proposal_custom_fields,
                            I18n.t("menu.title", scope: "decidim.decidim_awesome.admin.proposal_custom_fields"),
                            decidim_admin_decidim_awesome.config_path(:proposal_custom_fields),
                            position: 5.1,
                            icon_name: "draft-line"
            end

            if menus[:proposal_private_custom_fields].present?
              menu.add_item :proposal_private_custom_fields,
                            I18n.t("proposal_private_custom_fields", scope: "decidim.decidim_awesome.admin.proposal_custom_fields"),
                            decidim_admin_decidim_awesome.config_path(:proposal_private_custom_fields),
                            position: 5.2,
                            icon_name: "spy"
            end
          end
        end

        def register_custom_styles_submenu!
          Decidim.menu :custom_styles_submenu do |menu|
            if menus[:scoped_styles].present?
              menu.add_item :scoped_styles,
                            I18n.t("menu.title", scope: "decidim.decidim_awesome.admin.scoped_styles"),
                            decidim_admin_decidim_awesome.config_path(:scoped_styles),
                            position: 4.1,
                            icon_name: "computer-line"
            end

            if menus[:scoped_admin_styles].present?
              menu.add_item :scoped_admin_styles,
                            I18n.t("menu.title", scope: "decidim.decidim_awesome.admin.scoped_admin_styles"),
                            decidim_admin_decidim_awesome.config_path(:scoped_admin_styles),
                            position: 4.2,
                            icon_name: "file-settings-line"
            end
          end
        end

        def register_menu_hacks_submenu!
          Decidim.menu :menu_hacks_submenu do |menu|
            if menus[:menu_hacks_menu].present?
              menu.add_item :main_menu,
                            I18n.t("menu.title", scope: "decidim.decidim_awesome.admin.menu_hacks.index"),
                            decidim_admin_decidim_awesome.menu_hacks_path(:menu),
                            position: 7.1,
                            icon_name: "global-line"
            end

            if menus[:menu_hacks_mobile_menu].present?
              menu.add_item :mobile_menu,
                            I18n.t("mobile_menu.title", scope: "decidim.decidim_awesome.admin.menu_hacks.index"),
                            decidim_admin_decidim_awesome.menu_hacks_path(:mobile_menu),
                            position: 7.2,
                            icon_name: "smartphone"
            end

            if menus[:menu_hacks_home_content_block_menu].present?
              menu.add_item :content_block_main_menu,
                            I18n.t("home_content_block_menu.title", scope: "decidim.decidim_awesome.admin.menu_hacks.index"),
                            decidim_admin_decidim_awesome.menu_hacks_path(:home_content_block_menu),
                            position: 7.3,
                            icon_name: "layout-masonry-line"
            end
          end
        end

        def register_maintenance_admin_menu!
          Decidim.menu :maintenance_submenu do |menu|
            menu.add_item :private_data,
                          I18n.t("private_data", scope: "decidim.decidim_awesome.admin.menu.maintenance"),
                          decidim_admin_decidim_awesome.private_data_path,
                          position: 10,
                          icon_name: "spy-line"

            if config_enabled?(:hashcash_signup, :hashcash_login)
              menu.add_item :hashcash,
                            I18n.t("hashcash", scope: "decidim.decidim_awesome.admin.menu.maintenance"),
                            decidim_admin_decidim_awesome.hashcashes_path,
                            position: 10,
                            icon_name: "hashtag"
            end

            menu.add_item :checks,
                          I18n.t("checks", scope: "decidim.decidim_awesome.admin.menu.maintenance"),
                          decidim_admin_decidim_awesome.checks_path,
                          position: 10,
                          icon_name: "pulse"
          end
        end

        def menus
          @menus ||= {
            editors: config_enabled?(:allow_images_in_editors, :allow_videos_in_editors),
            proposals: config_enabled?(
              :allow_images_in_proposals,
              :validate_title_min_length, :validate_title_max_caps_percent,
              :validate_title_max_marks_together, :validate_title_start_with_caps,
              :validate_body_min_length, :validate_body_max_caps_percent,
              :validate_body_max_marks_together, :validate_body_start_with_caps
            ),
            surveys: config_enabled?(:auto_save_forms, :user_timezone, :hashcash_signup, :hashcash_login),
            styles: first_enabled(:scoped_styles, :scoped_admin_styles),
            scoped_styles: config_enabled?(:scoped_styles),
            scoped_admin_styles: config_enabled?(:scoped_admin_styles),
            custom_fields: first_enabled(:proposal_custom_fields, :proposal_private_custom_fields),
            proposal_custom_fields: config_enabled?(:proposal_custom_fields),
            proposal_private_custom_fields: config_enabled?(:proposal_private_custom_fields),
            admins: config_enabled?(:scoped_admins),
            menu_hacks: first_enabled(:menu, :mobile_menu, :home_content_block_menu),
            menu_hacks_menu: config_enabled?(:menu),
            menu_hacks_mobile_menu: config_enabled?(:mobile_menu),
            menu_hacks_home_content_block_menu: config_enabled?(:home_content_block_menu),
            custom_redirects: config_enabled?(:custom_redirects),
            livechat: config_enabled?(:intergram_for_admins, :intergram_for_public),
            verifications: config_enabled?(:force_authorization_after_login)
          }
        end

        def first_enabled(*vars)
          vars.each do |var|
            return var if config_enabled?(var)
          end
          nil
        end

        # ensure boolean value
        def config_enabled?(*vars)
          DecidimAwesome.enabled?(*vars)
        end
      end
    end
  end
end
