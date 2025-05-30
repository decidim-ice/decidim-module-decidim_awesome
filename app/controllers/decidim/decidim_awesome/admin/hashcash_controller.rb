# frozen_string_literal: true

require "decidim/decidim_awesome/version"

module Decidim
  module DecidimAwesome
    module Admin
      # System compatibility analyzer
      class HashcashController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig
        include MaintenanceContext
        helper ConfigConstraintsHelpers

        helper_method :stamps, :stamp, :addresses
        before_action do
          enforce_permission_to :edit_config, [:hashcash_login, :hashcash_signup]
        end

        def ip_addresses
          render "ip_addresses"
        end

        private

        def stamps
          @stamps ||= ActiveHashcash::Stamp.filter_by(params).order(created_at: :desc).limit(1000)
        end

        def stamp
          @stamp ||= ActiveHashcash::Stamp.find_by(id: params[:id])
        end

        def addresses
          @addresses ||= ActiveHashcash::Stamp.filter_by(params).group(:ip_address).order(count_all: :desc).limit(1000).count
        end
      end
    end
  end
end
