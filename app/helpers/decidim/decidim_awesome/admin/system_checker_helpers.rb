# frozen_string_literal: true

require "faraday"

module Decidim
  module DecidimAwesome
    module Admin
      module SystemCheckerHelpers
        def decidim_version
          Decidim.version
        end

        def decidim_version_valid?
          @decidim_version_valid ||= Gem::Dependency.new("", DecidimAwesome::COMPAT_DECIDIM_VERSION).match?("", decidim_version, true)
        end

        def awesome_version
          DecidimAwesome::VERSION
        end

        def awesome_latest_version
          @awesome_latest_version ||= fetch_latest_awesome_version
        end

        def awesome_version_outdated?
          return false unless awesome_latest_version

          current = Gem::Version.new(awesome_version)
          latest = Gem::Version.new(awesome_latest_version)
          current < latest
        end

        def overrides
          SystemChecker.to_h
        end

        def exists?(spec, file)
          SystemChecker.exists?(spec, file)
        end

        def valid?(spec, file)
          SystemChecker.valid?(spec, file)
        end

        def system_admin?
          DecidimAwesome.enabled?(:link_admin_to_system_admins) && current_user && current_user.admin? && system_admin.present?
        end

        def system_admin
          @system_admin ||= Decidim::System::Admin.find_by(email: current_user&.email)
        end

        private

        def fetch_latest_awesome_version
          Rails.cache.fetch("decidim_awesome_latest_version", expires_in: 1.hour) do
            fetch_from_github
          end
        rescue StandardError => e
          Rails.logger.error("Failed to fetch latest Decidim Awesome version: #{e.message}")
          nil
        end

        def fetch_from_github
          response = Faraday.get("https://api.github.com/repos/decidim-ice/decidim-module-decidim_awesome/releases")

          return nil unless response.success?

          releases = JSON.parse(response.body)
          current_minor = awesome_version.split(".")[0..1].join(".")

          # Find the latest release matching the current minor version
          matching_releases = releases.select do |release|
            version = release["tag_name"].gsub(/^v/, "")
            !release["draft"] && !release["prerelease"] && version.start_with?(current_minor)
          end

          matching_releases.first&.dig("tag_name")&.gsub(/^v/, "")
        end
      end
    end
  end
end
