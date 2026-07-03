# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class AwesomeAuthorizationHandler < Decidim::AuthorizationHandler
      validate :user_belongs_to_group

      def unique_id
        user.id.to_s
      end

      def metadata
        {
          groups: user_groups.to_h { |group| [group.id.to_s, group.name] }
        }
      end

      def to_partial_path
        "decidim/decidim_awesome/awesome_authorization_handler/form"
      end

      private

      def user_belongs_to_group
        return if organization.blank? || user_groups.any?

        errors.add(:base, I18n.t("decidim.decidim_awesome.awesome_authorization_handler.errors.user_not_in_group", email: user.email))
      end

      def user_groups
        @user_groups ||= organization.awesome_authorization_groups.joins(:members).where(members: { email: user.email })
      end

      def organization
        user&.organization
      end
    end
  end
end
