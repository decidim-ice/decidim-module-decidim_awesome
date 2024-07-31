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

          if permission_action.subject == :admin_accountability && DecidimAwesome.admin_accountability.respond_to?(:include?)
            if global?
              toggle_allow(DecidimAwesome.admin_accountability.include?(:admin_roles))
            else
              toggle_allow(DecidimAwesome.admin_accountability.include?(:participatory_space_roles))
            end
          elsif permission_action.subject == :private_data && config_enabled?(:proposal_private_custom_fields)
            if private_data.present?
              allow! if private_data.destroyable?
            else
              allow!
            end
          else
            toggle_allow(config_enabled?(*permission_action.subject))
          end

          permission_action
        end

        private

        def global?
          context.fetch(:global, nil)
        end

        def private_data
          context.fetch(:private_data, nil)
        end
      end
    end
  end
end
