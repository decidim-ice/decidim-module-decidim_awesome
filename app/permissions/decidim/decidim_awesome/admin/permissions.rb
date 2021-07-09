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

          toggle_allow(config_enabled?(permission_action.subject)) if permission_action.action == :edit_config

          permission_action
        end
      end
    end
  end
end
