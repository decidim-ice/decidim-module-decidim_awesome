# frozen_string_literal: true

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
      end
    end
  end
end
