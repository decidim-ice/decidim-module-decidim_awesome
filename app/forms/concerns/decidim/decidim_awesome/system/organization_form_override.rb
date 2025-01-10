# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module System
      module OrganizationFormOverride
        extend ActiveSupport::Concern

        included do
          alias_method :decidim_original_map_model, :map_model

          attribute :awesome_admins_available_authorizations, [String]

          def map_model(model)
            decidim_original_map_model(model)
            map_awesome_configs(model)
          end

          def clean_awesome_admins_available_authorizations
            return unless awesome_admins_available_authorizations

            awesome_admins_available_authorizations.compact_blank
          end

          private

          def map_awesome_configs(organization)
            self.awesome_admins_available_authorizations = Decidim::DecidimAwesome::AwesomeConfig.find_by(var: :admins_available_authorizations, organization:)&.value
          end
        end
      end
    end
  end
end
