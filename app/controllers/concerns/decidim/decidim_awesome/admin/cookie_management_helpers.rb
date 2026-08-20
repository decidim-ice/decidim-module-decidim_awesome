# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      module CookieManagementHelpers
        include BreadcrumbHelpers

        private

        def store
          @store ||= CookieManagementStore.new(current_organization, awesome_consent_categories)
        end

        def awesome_consent_categories
          Decidim::DecidimAwesome::AwesomeConfig.find_by(organization: current_organization, var: :cookie_management)&.value
        end
      end
    end
  end
end
