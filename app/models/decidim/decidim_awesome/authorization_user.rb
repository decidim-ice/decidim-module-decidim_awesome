# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class AuthorizationUser < ApplicationRecord
      self.table_name = "decidim_awesome_authorization_users"
      
      belongs_to :authorization_group, foreign_key: "authorization_group_id", class_name: "Decidim::DecidimAwesome::AuthorizationGroup"

      validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
      validates :email, uniqueness: { scope: :authorization_group_id, case_sensitive: false }

      before_validation :normalize_email

      private

      def normalize_email
        self.email = email&.downcase&.strip
      end
    end
  end
end
