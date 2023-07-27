# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class AdminAccountabilityController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig
        include Decidim::DecidimAwesome::AdminAccountability::Admin::Filterable

        helper_method :admin_actions, :collection, :export_params, :global?, :global_users_missing_date

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
          @collection = global? ? paginate(admin_role_actions) : paginate(space_role_actions)
        end

        def space_role_actions
          @space_role_actions ||= Decidim::DecidimAwesome::PaperTrailVersion.space_role_actions(current_organization)
        end

        def admin_role_actions
          @admin_role_actions ||= Decidim::DecidimAwesome::PaperTrailVersion.in_organization(current_organization).admin_role_actions(params[:admin_role_type])
        end

        def export_params
          params.permit(:format, :admins, :admin_role_type, q: [:role_type_eq, :user_name_or_user_email_cont, :created_at_gteq, :created_at_lteq])
        end

        def global?
          params[:admins] == "true"
        end

        # User traceability was introduced in version 0.24. Users created before that might appear in the list.
        # Returns the first traceability record available if there are users created before.
        # Returns nil otherwise
        def global_users_missing_date
          return unless global?

          @global_users_missing_date ||= begin
            first_version = Decidim::DecidimAwesome::PaperTrailVersion.where(item_type: "Decidim::UserBaseEntity").last
            first_user = Decidim::User.first
            first_version.created_at if first_user && first_version && (first_version.created_at > first_user.created_at + 1.second)
          end
        end
      end
    end
  end
end
