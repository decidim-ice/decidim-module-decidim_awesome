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

      def organization_awesome_config
        @organization_awesome_config ||= awesome_config_instance.organization_config
      end

      def awesome_version
        ::Decidim::DecidimAwesome::VERSION
      end

      def tenant_stylesheets
        return @tenant_stylesheets if @tenant_stylesheets

        prefix = Rails.root.join("app", "assets", "themes", current_organization.host)
        return @tenant_stylesheets = current_organization.host.to_s if File.exist?("#{prefix}.css") || File.exist?("#{prefix}.scss")
      end

      def version_prefix
        return "v0.21" if Decidim.version.start_with? "0.21"

        "v0.22"
      end
    end
  end
end
