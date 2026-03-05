# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class UsersAutoblockCalculateJob < ApplicationJob
      queue_as :default

      def perform(admin)
        @admin = admin
        calculate_scores
      end

      private

      def calculate_scores
        exporter = Decidim::DecidimAwesome::UsersAutoblocksScoresExporter.new(@admin.organization, users_base_relation)
        exporter.export
      end

      def users_base_relation
        @users_base_relation ||= Decidim::User
          .where(organization: @admin.organization)
          .joins("LEFT JOIN decidim_authorizations ON decidim_authorizations.decidim_user_id = decidim_users.id")
          .where(decidim_authorizations: { granted_at: nil })
          .where.not(admin: true)
          .not_deleted
          .not_blocked
      end
    end
  end
end
