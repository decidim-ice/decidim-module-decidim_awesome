# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      module MaintenanceContext
        extend ActiveSupport::Concern

        included do
          layout "decidim/decidim_awesome/admin/maintenance"
        end
      end
    end
  end
end
