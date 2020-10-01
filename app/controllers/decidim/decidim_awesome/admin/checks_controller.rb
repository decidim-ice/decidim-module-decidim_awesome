# frozen_string_literal: true

require "decidim/decidim_awesome/version"

module Decidim
  module DecidimAwesome
    module Admin
      # System compatibility analyzer
      class ChecksController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig

        layout "decidim/admin/decidim_awesome"

        helper_method :overrides, :valid?, :decidim_version, :decidim_version_valid?

        private

        def overrides
          SystemChecker.to_h
        end

        def valid?(spec, file)
          SystemChecker.valid?(spec, file)
        end

        def decidim_version
          Decidim.version
        end

        def decidim_version_valid?
          ::Gem::Version.new(DecidimAwesome::MIN_DECIDIM_VERSION) <= ::Gem::Version.new(decidim_version)
        end
      end
    end
  end
end
