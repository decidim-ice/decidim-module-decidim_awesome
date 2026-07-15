# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class AuthorizationMember < ApplicationRecord
      self.table_name = "decidim_awesome_authorization_members"

      belongs_to :authorization_group, class_name: "Decidim::DecidimAwesome::AuthorizationGroup"

      validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
      validates :email, uniqueness: { scope: :authorization_group_id, case_sensitive: false }

      before_validation :normalize_email

      delegate :organization, to: :authorization_group

      def user
        @user ||= organization.users.find_by(email: email)
      end

      def authorization
        @authorization ||= Decidim::Authorization.find_by(name: :awesome_authorization_handler, user: user)
      end

      def group_authorized?(authorization_group)
        return false unless authorization

        authorization.metadata["groups"]&.include?(authorization_group.id.to_s)
      end

      def self.ransackable_associations(_auth_object = nil)
        []
      end

      def self.ransackable_attributes(_auth_object = nil)
        %w(email)
      end

      private

      def normalize_email
        self.email = email&.downcase&.strip
      end
    end
  end
end
