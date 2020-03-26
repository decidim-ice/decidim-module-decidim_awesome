# frozen_string_literal: true

module Decidim
  # add a global helper with awesome configuration
  module DecidimAwesome
    module AwesomeHelpers
      # The current awesome config for the organization.
      #
      # Returns an Organization.
      def awesome_config
        @awesome_config ||= DecidimAwesome.config.map do |key, val|
          [key, request.env["decidim_awesome.current_config"][key].presence || val]
        end.to_h
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
