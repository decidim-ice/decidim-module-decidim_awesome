# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module System
      module UpdateOrganizationOverride
        extend ActiveSupport::Concern

        included do
          private

          alias_method :decidim_original_save_organization, :save_organization

          def save_organization
            decidim_original_save_organization
            add_awesome_configs!
          end

          def add_awesome_configs!
            allowed = AwesomeConfig.find_or_initialize_by(var: :admins_available_authorizations, organization: @organization)
            allowed.value = form.clean_awesome_admins_available_authorizations
            allowed.save!
          end
        end
      end
    end
  end
end
