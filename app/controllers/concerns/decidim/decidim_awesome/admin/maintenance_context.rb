# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      module MaintenanceContext
        extend ActiveSupport::Concern

        included do
          layout "decidim/decidim_awesome/admin/maintenance"
          helper_method :available_views

          private

          def available_views
            {
              "private_data" => {
                title: I18n.t("private_data", scope: "decidim.decidim_awesome.admin.menu.maintenance"),
                icon: "spy-line",
                path: decidim_admin_decidim_awesome.private_data_path
              },
              "hashcash" => {
                title: I18n.t("hashcash", scope: "decidim.decidim_awesome.admin.menu.maintenance"),
                icon: "hashtag",
                path: decidim_admin_decidim_awesome.hashcashes_path
              },
              "checks" => {
                title: I18n.t("checks", scope: "decidim.decidim_awesome.admin.menu.maintenance"),
                icon: "pulse",
                path: decidim_admin_decidim_awesome.checks_path
              }
            }
          end
        end
      end
    end
  end
end
