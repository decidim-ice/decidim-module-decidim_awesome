# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class AuthorizationGroup < ApplicationRecord
      self.table_name = "decidim_awesome_authorization_groups"

      belongs_to :organization, foreign_key: "decidim_organization_id", class_name: "Decidim::Organization"
      has_many :authorization_members, class_name: "Decidim::DecidimAwesome::AuthorizationMember", dependent: :destroy

      validates :name, presence: true
      validates :purpose, presence: true

      def user_count
        authorization_members.count
      end

      def authorized_count
        # TODO: Implement when authorization tracking is added
        0
      end
    end
  end
end
