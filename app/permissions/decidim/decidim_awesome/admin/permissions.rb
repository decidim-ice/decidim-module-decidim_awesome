# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class Permissions < Decidim::DefaultPermissions
        include ConfigConstraintsHelpers

        def permissions
          return permission_action if permission_action.scope != :admin
          return permission_action unless user
          return permission_action if user.read_attribute("admin").blank?
          return permission_action unless permission_action.action == :edit_config

          return permission_action unless config_enabled?(*permission_action.subject)

          apply_admin_accountability_permissions!
          apply_private_data_permissions!
          apply_admin_authorizations_permissions!

          permission_action
        end

        private

        def apply_admin_authorizations_permissions!
          allow! if permission_action.subject == :admins_available_authorizations && handler.in?(awesome_admin_authorizations)
        end

        def apply_admin_accountability_permissions!
          if permission_action.subject == :admin_accountability && DecidimAwesome.admin_accountability.respond_to?(:include?)
            if global?
              allow! if DecidimAwesome.admin_accountability.include?(:admin_roles)
            elsif DecidimAwesome.admin_accountability.include?(:participatory_space_roles)
              allow!
            end
          end
        end

        def apply_private_data_permissions!
          if permission_action.subject == :private_data
            if private_data.present?
              allow! if private_data.destroyable?
            else
              allow!
            end
          end
        end

        def global?
          context.fetch(:global, nil)
        end

        def private_data
          context.fetch(:private_data, nil)
        end

        def handler
          context.fetch(:handler, "")
        end

        def awesome_admin_authorizations
          @awesome_admin_authorizations ||= AwesomeConfig.find_by(var: :admins_available_authorizations, organization: user.organization)&.value || []
        end
      end
    end
  end
end
