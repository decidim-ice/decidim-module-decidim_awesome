# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class Permissions < Decidim::DefaultPermissions
        include ConfigConstraintsHelpers

        def permissions
          return permission_action if permission_action.scope != :admin
          return permission_action unless user

          if permission_action.subject == :follow_up_questionnaire_messages
            apply_follow_up_questionnaire_message_permissions!
            return permission_action
          end

          if permission_action.action == :update && permission_action.subject == :organization
            allow! if user.read_attribute("admin").present? || user_administrator?
            return permission_action
          end

          return permission_action if user.read_attribute("admin").blank?
          return permission_action unless permission_action.action == :edit_config

          apply_private_data_permissions!
          if config_enabled?(*permission_action.subject)
            case permission_action.subject
            when :admins_available_authorizations
              apply_admin_authorizations_permissions!
            when :admin_accountability
              apply_admin_accountability_permissions!
            else
              allow!
            end
          end

          permission_action
        end

        private

        def user_administrator?
          DecidimAwesome.participatory_space_roles.any? { |role_class_name| space_admin?(role_class_name) }
        end

        def apply_follow_up_questionnaire_message_permissions!
          space = context.fetch(:current_participatory_space, nil)
          return unless space

          role_class_name = "#{space.class.name}UserRole"
          return unless DecidimAwesome.participatory_space_roles.include?(role_class_name)

          allow! if space_admin?(role_class_name, space)
        end

        def space_admin?(role_class_name, space = nil)
          role_class = role_class_name.safe_constantize
          return false unless role_class

          scope = role_class.where(role: "admin", decidim_user_id: user.id)
          scope = scope.for_space(space) if space
          scope.exists?
        end

        def apply_admin_authorizations_permissions!
          allow! if awesome_admin_authorizations.present? && handler.in?(awesome_admin_authorizations)
        end

        def apply_admin_accountability_permissions!
          if DecidimAwesome.admin_accountability.respond_to?(:include?)
            if global?
              allow! if DecidimAwesome.admin_accountability.include?(:admin_roles)
            elsif DecidimAwesome.admin_accountability.include?(:participatory_space_roles)
              allow!
            end
          end
        end

        def apply_private_data_permissions!
          return unless permission_action.subject == :private_data && config_enabled?(:proposal_private_custom_fields)

          if private_data.present?
            allow! if private_data.destroyable?
          else
            allow!
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
          @awesome_admin_authorizations ||= begin
            handlers = AwesomeConfig.find_by(var: :admins_available_authorizations, organization: user.organization)&.value || []
            user.organization.available_authorizations.intersection(handlers)
          end
        end
      end
    end
  end
end
