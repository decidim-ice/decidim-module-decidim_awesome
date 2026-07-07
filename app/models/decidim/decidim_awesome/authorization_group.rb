# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class AuthorizationGroup < ApplicationRecord
      self.table_name = "decidim_awesome_authorization_groups"

      belongs_to :organization, foreign_key: "decidim_organization_id", class_name: "Decidim::Organization"
      has_many :members, class_name: "Decidim::DecidimAwesome::AuthorizationMember", dependent: :destroy

      validates :name, presence: true
      validates :purpose, presence: true

      def self.authorizations(organization)
        Decidim::Verifications::Authorizations.new(organization: organization, name: :awesome_authorization_handler, granted: true).query
      end

      def self.sync_user_authorization(user)
        handler = Decidim::AuthorizationHandler.handler_for("awesome_authorization_handler", user: user)

        if handler.valid?
          Decidim::Authorization.create_or_update_from(handler)
        else
          Decidim::Authorization.find_by(user: user, name: "awesome_authorization_handler")&.destroy!
        end
      end

      def reset_caches!
        @members_count = nil
        @authorizations_in_group = nil
        @granted_in_group = nil
        @granted_in_group_count = nil
        @users = nil
        @users_count = nil
      end

      def members_count
        @members_count ||= members.count
      end

      def authorizations_in_group
        @authorizations_in_group ||= AuthorizationGroup.authorizations(organization).select { |authorization| authorization.metadata["groups"]&.include?(id.to_s) }
      end

      def granted_in_group
        @granted_in_group ||= organization.users.where(id: authorizations_in_group.pluck(:decidim_user_id))
      end

      def granted_in_group_count
        @granted_in_group_count ||= granted_in_group.count
      end

      def users
        @users ||= organization.users.where(email: members.select(:email))
      end

      def users_count
        @users_count ||= users.count
      end

      def synced?
        users.pluck(:id).sort == granted_in_group.pluck(:id).sort
      end
    end
  end
end
