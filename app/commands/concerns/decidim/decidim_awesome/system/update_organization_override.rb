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
            if form.clean_awesome_admins_available_authorizations.present?
              add_awesome_configs!
            elsif awesome_config&.persisted?
              awesome_config.destroy!
            end
          end

          def add_awesome_configs!
            awesome_config.value = form.clean_awesome_admins_available_authorizations
            awesome_config.save!
          end

          def awesome_config
            @awesome_config ||= AwesomeConfig.find_or_initialize_by(var: :admins_available_authorizations, organization: @organization)
          end
        end
      end
    end
  end
end
