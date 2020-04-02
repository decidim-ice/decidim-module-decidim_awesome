# frozen_string_literal: true

require "decidim/decidim_awesome/version"

module Decidim
  # add a global helper with awesome configuration
  module DecidimAwesome
    module AwesomeHelpers
      # The current awesome config for the organization.
      #
      # Returns the normalized config for an Organization.
      def awesome_config
        request.env["decidim_awesome.current_config"]
      end

      def awesome_config_tag
        content_tag :script, render(partial: "layouts/decidim/decidim_awesome/awesome_config.js")
      end

      def awesome_version
        ::Decidim::DecidimAwesome::VERSION
      end
    end
  end
end
