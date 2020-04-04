# frozen_string_literal: true

require "decidim/decidim_awesome/version"

module Decidim
  # add a global helper with awesome configuration
  module DecidimAwesome
    module AwesomeHelpers
      # Returns the normalized config for an Organization and the current url
      def awesome_config_instance
        return @awesome_config_instance if @awesome_config_instance

        @awesome_config_instance = Config.new request.env["decidim.current_organization"]
        @awesome_config_instance.context_from_request request
        @awesome_config_instance
      end

      def awesome_config
        @awesome_config ||= awesome_config_instance.config
      end

      def unfiltered_awesome_config
        @unfiltered_awesome_config ||= awesome_config_instance.unfiltered_config
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
