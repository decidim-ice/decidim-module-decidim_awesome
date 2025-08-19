# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class Menu
      class << self
        def register_simple_entry(menu_registry, name, position, icon, options = {})
          return if menus[name].blank?

          Decidim.menu menu_registry do |menu|
            i18n_key = options[:i18n_key].presence || "menu.#{name}"
            extra = {}.tap do |hash|
              hash[:submenu] = options[:submenu] if options[:submenu].present?
              if options[:active].present?
                hash[:active] = false
                options[:active].each do |active_path|
                  hash[:active] ||= is_active_link?(decidim_admin_decidim_awesome.send(active_path[0], *active_path[1..]))
                end
              end
            end
            path = main_path_for(name)
            menu.add_item name,
                          I18n.t(i18n_key, scope: "decidim.decidim_awesome.admin"),
                          decidim_admin_decidim_awesome.send(path[0], path[1]),
                          position:,
                          icon_name: icon,
                          **extra
          end
        end

        def main_path_for(config_var)
          case config_var.to_sym
          when :styles
            [:config_path, [menus[:styles]]]
          when :custom_fields
            [:config_path, [menus[:custom_fields]]]
          when :menu_hacks
            [:menu_hacks_path, [menus[:menu_hacks]]]
          when :custom_redirects
            [:custom_redirects_path, []]
          when :maintenance
            [:checks_path, []]
          else
            [:config_path, [config_var]]
          end
        end

        def register_awesome_admin_menu!
          register_simple_entry(:awesome_admin_menu, :editors, 1, "editors-text")
          register_simple_entry(:awesome_admin_menu, :proposals, 2, "documents")
          register_simple_entry(:awesome_admin_menu, :surveys, 3, "surveys")
          register_simple_entry(:awesome_admin_menu, :styles, 4, "brush",
                                submenu: { target_menu: :custom_styles_submenu },
                                active: [[:config_path, :scoped_styles], [:config_path, :scoped_admin_styles]])

          register_simple_entry(:awesome_admin_menu, :custom_fields, 5, "layers",
                                i18n_key: "menu.proposal_custom_fields",
                                submenu: { target_menu: :custom_fields_submenu },
                                active: [[:config_path, :proposal_custom_fields], [:config_path, :proposal_private_custom_fields]])

          register_simple_entry(:awesome_admin_menu, :admins, 6, "group-line")

          register_simple_entry(:awesome_admin_menu, :menu_hacks, 7, "menu-line",
                                submenu: { target_menu: :menu_hacks_submenu },
                                active: [[:menu_hacks_path, :menu], [:menu_hacks_path, :mobile_menu], [:menu_hacks_path, :home_content_block_menu]])

          register_simple_entry(:awesome_admin_menu, :custom_redirects, 8, "external-link-line")
          register_simple_entry(:awesome_admin_menu, :livechat, 9, "chat-1-line")
          register_simple_entry(:awesome_admin_menu, :verifications, 10, "fingerprint-line")

          register_simple_entry(:awesome_admin_menu, :maintenance, 11, "tools-line",
                                i18n_key: "menu.maintenance.maintenance",
                                submenu: { target_menu: :maintenance_submenu },
                                active: [[:private_data_path], [:hashcashes_path], [:checks_path]])
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
            if config_enabled?(:proposal_private_custom_fields)
              menu.add_item :private_data,
                            I18n.t("private_data", scope: "decidim.decidim_awesome.admin.menu.maintenance"),
                            decidim_admin_decidim_awesome.private_data_path,
                            position: 10.1,
                            icon_name: "spy-line"
            end

            if config_enabled?(:hashcash_signup, :hashcash_login)
              menu.add_item :hashcash,
                            I18n.t("hashcash", scope: "decidim.decidim_awesome.admin.menu.maintenance"),
                            decidim_admin_decidim_awesome.hashcashes_path,
                            position: 10.2,
                            icon_name: "hashtag"
            end

            menu.add_item :checks,
                          I18n.t("checks", scope: "decidim.decidim_awesome.admin.menu.maintenance"),
                          decidim_admin_decidim_awesome.checks_path,
                          position: 10.3,
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
            verifications: config_enabled?(:force_authorizations),
            maintenance: true
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
