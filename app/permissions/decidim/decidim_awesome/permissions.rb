# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action unless user

        return Decidim::DecidimAwesome::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin

        editor_image_action?
        required_authorizations_action?

        permission_action
      end

      def editor_image_action?
        return unless permission_action.subject == :editor_image

        config = context.fetch(:awesome_config, {})

        return allow! if user.admin?
        return allow! if config[:allow_images_in_proposals]
        return allow! if config[:allow_images_in_small_editor]
        return allow! if config[:allow_images_in_full_editor]
        return allow! if config[:allow_images_in_markdown_editor]
      end

      def required_authorizations_action?
        return false unless permission_action.subject == :required_authorizations

        return allow! unless context[:user_is_authorized]
      end
    end
  end
end
