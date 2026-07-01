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

      def granted_count
        @granted_count ||= Decidim::Verifications::Authorizations.new(organization: organization, name: :awesome_authorization_handler, granted: true).query.count
      end
    end
  end
end
