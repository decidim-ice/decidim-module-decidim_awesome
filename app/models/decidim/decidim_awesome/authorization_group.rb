# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class AuthorizationGroup < ApplicationRecord
      self.table_name = "decidim_awesome_authorization_groups"

      belongs_to :organization, foreign_key: "decidim_organization_id", class_name: "Decidim::Organization"
      has_many :members, class_name: "Decidim::DecidimAwesome::AuthorizationMember", dependent: :destroy

      validates :name, presence: true
      validates :purpose, presence: true

      def members_count
        @members_count ||= members.count
      end

      def granted
        @granted ||= Decidim::Verifications::Authorizations.new(organization: organization, name: :awesome_authorization_handler, granted: true).query.where(user: users)
      end

      def granted_count
        @granted_count ||= granted.count
      end

      def granted_in_group
        @granted_in_group ||= granted.select { |authorization| authorization.metadata["groups"]&.include?(id.to_s) }
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

      def not_authorized_users
        @not_authorized_users ||= users - granted.map(&:user)
      end

      def synced?
        granted_in_group_count == users_count
      end
    end
  end
end
