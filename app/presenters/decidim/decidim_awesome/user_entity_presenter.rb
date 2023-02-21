# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class UserEntityPresenter < RoleBasePresenter
      # Finds the destroyed entry if exists
      def destroy_entry
        @destroy_entry ||= PaperTrail::Version.where(item_type: item_type, event: "update", item_id: item_id).where("id > ?", entry.id).first
      end

      def roles
        @roles ||= begin
          rls = entry.changeset["roles"]&.last || []
          rls << "admin" if entry.changeset["admin"]&.last
          rls
        end
      end

      def role_name
        types = roles.index_with { |role| I18n.t(role, scope: "decidim.decidim_awesome.admin.admin_accountability.admin_roles", default: role) }
        return types.values.join(", ") unless html

        types.map { |role, type| "<span class=\"#{role_class(role)}\">#{type}</span>" }.join(" ").html_safe
      end

      def user
        @user ||= entry&.item || Decidim::User.find_by(id: entry.changeset["id"]&.last)
      end

      private

      def role_class(role)
        case role
        when "admin"
          "text-alert"
        when "user_manager"
          "text-secondary"
        end
      end
    end
  end
end
