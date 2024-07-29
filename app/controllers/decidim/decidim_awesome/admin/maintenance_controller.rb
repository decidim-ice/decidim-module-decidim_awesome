# frozen_string_literal: true

require "decidim/decidim_awesome/version"

module Decidim
  module DecidimAwesome
    module Admin
      # System compatibility analyzer
      class MaintenanceController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig
        include MaintenanceContext
        helper ConfigConstraintsHelpers
        include Decidim::Admin::Filterable
        helper_method :filtered_collection

        def show; end

        private

        def collection
          @collection = paginate(private_data)
        end

        def base_query
          collection
        end

        def private_data
          # TODO: only after a date
          @private_data = PrivateDataFinder.new.query
        end
      end
    end
  end
end
