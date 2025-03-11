# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module System
      module CreateOrganizationOverride
        extend ActiveSupport::Concern

        included do
          private

          alias_method :decidim_create_organization, :create_organization

          def create_organization
            @organization = decidim_create_organization
            if form.clean_awesome_admins_available_authorizations.present?
              AwesomeConfig.create!(
                var: :admins_available_authorizations,
                organization: @organization,
                value: form.clean_awesome_admins_available_authorizations
              )
            end
            @organization
          end
        end
      end
    end
  end
end
