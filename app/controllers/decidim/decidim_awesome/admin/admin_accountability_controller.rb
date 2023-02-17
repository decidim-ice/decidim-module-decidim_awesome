# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class AdminAccountabilityController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig
        include Decidim::DecidimAwesome::AdminAccountability::Admin::Filterable

        helper_method :admin_actions, :admin_action, :collection

        layout "decidim/admin/users"

        before_action do
          enforce_permission_to :edit_config, :allow_admin_accountability
        end

        def index
          @render_date_fields = true
        end

        def export
          # TODO: export to xls, csv
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
      end
    end
  end
end
