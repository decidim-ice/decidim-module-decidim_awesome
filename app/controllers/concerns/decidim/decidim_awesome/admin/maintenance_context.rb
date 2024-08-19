# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      module MaintenanceContext
        extend ActiveSupport::Concern

        included do
          layout "decidim/decidim_awesome/admin/maintenance"
          helper_method :current_view, :available_views, :present_private_data

          private

          def present_private_data(model)
            PrivateDataPresenter.new(model)
          end

          def current_view
            return params[:id] if available_views.include?(params[:id])

            available_views.keys.first
          end

          def available_views
            {
              "private_data" => {
                title: I18n.t("private_data", scope: "decidim.decidim_awesome.admin.menu.maintenance"),
                icon: "lock-locked",
                path: decidim_admin_decidim_awesome.maintenance_path("private_data")
              },
              "checks" => {
                title: I18n.t("checks", scope: "decidim.decidim_awesome.admin.menu.maintenance"),
                icon: "pulse",
                path: decidim_admin_decidim_awesome.checks_maintenance_index_path
              }
            }
          end
        end
      end
    end
  end
end
