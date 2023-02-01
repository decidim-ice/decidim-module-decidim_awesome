# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class PaperTrailRolePresenter < Decidim::Log::BasePresenter
      include TranslatableAttributes

      attr_reader :entry, :html

      def initialize(entry, html: true)
        @entry = entry
        @html = html
      end

      # try to use the object in the database if exists
      # Note that "reify" does not work on "create" events
      def item
        @item ||= entry&.item
      end

      # Finds the destroyed entry if exists
      def destroy_entry
        @destroy_entry ||= PaperTrail::Version.find_by(item_type: entry.item_type, event: "destroy", item_id: entry.item_id)
      end

      alias destroyed? destroy_entry

      # try to reconstruct a destroyed event
      def destroy_item
        @destroy_item ||= destroy_entry&.reify
      end

      # participatory spaces is in the normal entry if the role hasn't been removed
      # otherwise is in the removed role log entry
      def participatory_space
        item&.participatory_space || destroy_item&.participatory_space
      end

      # roles are in the destroyed event if the role has been removed
      def role
        @role ||= destroy_item&.role || item&.role
      end

      def role_class
        case role
        when "admin"
          "text-alert"
        when "valuator"
          "text-secondary"
        end
      end

      def role_name
        I18n.t(role, scope: "decidim.decidim_awesome.admin.admin_accountability.roles", default: role)
      end

      def participatory_space_name
        "#{participatory_space_type} > #{translated_attribute participatory_space&.title}"
      end

      def participatory_space_type
        I18n.t(participatory_space&.manifest&.name, scope: "decidim.admin.menu", default: entry.changeset)
      end

      # try to link to the user roles page or to the participatory space if not existing
      def participatory_space_path
        proxy.send("#{participatory_space.manifest.route_name}_user_roles_path")
      rescue NoMethodError
        begin
          proxy.send("#{participatory_space.manifest.route_name}_path", participatory_space)
        rescue NoMethodError
          ""
        end
      end

      def user
        @user ||= Decidim::User.find_by(id: entry.changeset["decidim_user_id"]&.last)
      end

      def user_name
        return I18n.t("missing_user", scope: "decidim.decidim_awesome.admin.admin_accountability") unless user
        return I18n.t("deleted_user", scope: "decidim.decidim_awesome.admin.admin_accountability") if user.deleted?

        user&.name
      end

      def user_email
        user&.email
      end

      def created_at
        entry.changeset["created_at"]&.last || entry&.created_at
      end

      def created_date
        I18n.l(created_at, format: :short)
      rescue I18n::ArgumentError
        ""
      end

      def destroyed_at
        destroy_entry&.created_at
      end

      def removal_date
        I18n.l(destroyed_at, format: :short)
      rescue I18n::ArgumentError
        info_text("currently_active", klass: "text-success")
      end

      def last_sign_in_date
        I18n.l(user&.last_sign_in_at, format: :short)
      rescue I18n::ArgumentError
        info_text("never_logged")
      end

      private

      def info_text(key, klass: :muted)
        text = I18n.t(key, scope: "decidim.decidim_awesome.admin.admin_accountability")
        return text unless html

        "<span class=\"#{klass}\">#{text}</span>".html_safe
      end

      def proxy
        @proxy ||= Decidim::EngineRouter.admin_proxy(participatory_space)
      end
    end
  end
end
