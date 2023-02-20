# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class AdminAccountabilityController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig
        include Decidim::DecidimAwesome::AdminAccountability::Admin::Filterable

        helper_method :admin_actions, :collection, :export_params, :global?

        layout "decidim/admin/users"

        before_action do
          enforce_permission_to :edit_config, :admin_accountability, global: global?
        end

        def index; end

        def export
          filters = export_params[:q]

          Decidim::DecidimAwesome::ExportAdminActionsJob.perform_later(current_user,
                                                                       params[:format].to_s,
                                                                       admin_actions.ransack(filters).result.ids)

          redirect_back fallback_location: decidim_admin_decidim_awesome.admin_accountability_path,
                        notice: t("decidim.decidim_awesome.admin.admin_accountability.exports.notice")
        end

        private

        def admin_actions
          @admin_actions ||= filtered_collection
        end

        def collection
          @collection ||= paginate(global? ? PaperTrailVersion.admin_role_actions(params[:admin_role_type]) : PaperTrailVersion.space_role_actions)
        end

        def export_params
          params.permit(:format, :admins, :admin_role_type, q: [:role_type_eq, :user_name_or_user_email_cont, :created_at_gteq, :created_at_lteq])
        end

        def global?
          params[:admins] == "true"
        end
      end
    end
  end
end
