# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class RoleBasePresenter < PaperTrailBasePresenter
      include TranslatableAttributes

      # Finds the destroyed entry if exists
      def destroy_entry
        nil
      end

      alias destroyed? destroy_entry

      # try to reconstruct a destroyed event
      def destroy_item
        @destroy_item ||= destroy_entry&.reify
      end

      def user
        raise "Please implement this method to return the user object"
      end

      def role_name
        raise "Please implement this method to return the role text"
      end

      def participatory_space
        nil
      end

      def participatory_space_name
        participatory_space_type.present? ? "#{participatory_space_type} > #{translated_attribute participatory_space&.title}" : ""
      end

      def participatory_space_type
        I18n.t(participatory_space&.manifest&.name, scope: "decidim.admin.menu") if participatory_space.present?
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

      def user_name
        return I18n.t("missing_user", scope: "decidim.decidim_awesome.admin.admin_accountability") unless user
        return I18n.t("deleted_user", scope: "decidim.decidim_awesome.admin.admin_accountability") if user.deleted?

        user&.name
      end

      def user_email
        user&.email || entry.changeset["email"]&.last
      end

      def created_at
        DateTime.parse(entry.changeset["created_at"]&.last)
      rescue StandardError
        entry&.created_at
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

      protected

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
