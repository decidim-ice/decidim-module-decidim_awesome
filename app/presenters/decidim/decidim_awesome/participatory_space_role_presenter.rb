# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class ParticipatorySpaceRolePresenter < RoleBasePresenter
      # Finds the destroyed entry if exists
      def destroy_entry
        @destroy_entry ||= PaperTrail::Version.find_by(item_type:, event: "destroy", item_id:)
      end

      # roles are in the destroyed event if the role has been removed
      def role
        @role ||= destroy_item&.role || item&.role
      end

      def role_name
        type = I18n.t(role, scope: "decidim.decidim_awesome.admin.admin_accountability.roles", default: role)
        return type unless html && role_class

        "<span class=\"#{role_class}\">#{type}</span>".html_safe
      end

      def user
        @user ||= Decidim::User.find_by(id: entry.changeset["decidim_user_id"]&.last)
      end

      # participatory spaces is in the normal entry if the role hasn't been removed
      # otherwise is in the removed role log entry
      def participatory_space
        item&.participatory_space || destroy_item&.participatory_space
      end

      private

      def role_class
        case role
        when "admin"
          "text-alert"
        when "valuator"
          "text-secondary"
        end
      end
    end
  end
end
