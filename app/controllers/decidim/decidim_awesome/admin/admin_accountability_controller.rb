# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class AdminAccountabilityController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig
        include Decidim::Admin::Filterable

        helper_method :admin_actions

        layout "decidim/admin/users"

        before_action do
          enforce_permission_to :edit_config, :allow_admin_accountability
        end

        def index; end

        def export
          # TODO: export to xls, csv
        end

        private

        def admin_actions
          @admin_actions ||= paginate(PaperTrailVersion.role_actions)
        end
      end
    end
  end
end
