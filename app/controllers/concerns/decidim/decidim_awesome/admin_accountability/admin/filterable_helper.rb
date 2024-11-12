# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module AdminAccountability
      module Admin
        module FilterableHelper
          def extra_dropdown_submenu_options_items(_filter, _i18n_scope)
            Decidim.user_roles.sort.map do |role_type|
              link_to(I18n.t(role_type, scope: "decidim.decidim_awesome.admin.admin_accountability.admin_roles"),
                      url_for(export_params.merge({ admin_role_type: role_type })))
            end
          end

          def applied_filters_tags(i18n_ctx)
            admin_role_type = PaperTrailVersion.safe_admin_role_type(params[:admin_role_type])
            if global? && admin_role_type.present?
              content_tag(:span, class: "label secondary") do
                concat "#{i18n_filter_label(:admin_role_type, filterable_i18n_scope_from_ctx(i18n_ctx))}: "
                concat t("decidim.decidim_awesome.admin.admin_accountability.admin_roles.#{admin_role_type}", default: admin_role_type)
                concat icon_link_to(
                  "circle-x",
                  url_for(export_params.except(:admin_role_type)),
                  t("decidim.admin.actions.cancel"),
                  class: "action-icon--remove"
                )
              end
            else
              ransack_params.slice(*filters).map do |filter, value|
                applied_filter_tag(filter, value, filterable_i18n_scope_from_ctx(i18n_ctx))
              end.join.html_safe
            end
          end
        end
      end
    end
  end
end
