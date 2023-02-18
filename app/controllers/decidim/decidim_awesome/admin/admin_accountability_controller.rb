# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class AdminAccountabilityController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig
        include Decidim::DecidimAwesome::AdminAccountability::Admin::Filterable

        helper_method :admin_actions, :admin_action, :collection, :export_params

        layout "decidim/admin/users"

        before_action do
          enforce_permission_to :edit_config, :allow_admin_accountability
        end

        def index; end

        def export
          format = params[:format].to_s
          filters = export_params[:q]

          Decidim::DecidimAwesome::ExportAdminActionsJob.perform_later(current_user, format, admin_actions.ransack(filters).result.ids)

          redirect_to decidim_admin_decidim_awesome.admin_accountability_path, notice: t("decidim.decidim_awesome.admin.admin_accountability.exports.notice")
        end

        private

        def admin_actions
          @admin_actions ||= filtered_collection
        end

        def collection
          @collection ||= paginate(PaperTrailVersion.role_actions)
        end

        def admin_action
          @admin_action ||= collection.find(params[:id])
        end

        def export_params
          params.permit(:format, q: [:role_type_eq, :user_name_or_user_email_cont, :created_at_gteq, :created_at_lteq])
        end
      end
    end
  end
end
