# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class SyncAwesomeAuthorizationGroupJob < ApplicationJob
      queue_as :default

      def perform(authorization_group_id)
        @authorization_group = Decidim::DecidimAwesome::AuthorizationGroup.find_by(id: authorization_group_id)
        return unless authorization_group

        authorization_group.reset_caches!

        authorization_group.users.each do |user|
          sync_user_authorization(user)
        end

        # clean up authorizations for users that are no longer members of the group
        (authorization_group.granted_in_group - authorization_group.users).each do |user|
          Decidim::Authorization.find_by(user: user, name: "awesome_authorization_handler")&.destroy!
        end
      end

      private

      attr_reader :authorization_group

      def sync_user_authorization(user)
        handler = Decidim::AuthorizationHandler.handler_for("awesome_authorization_handler", user: user)

        if handler.valid?
          Decidim::Authorization.create_or_update_from(handler)
        else
          Decidim::Authorization.find_by(user: user, name: "awesome_authorization_handler")&.destroy!
        end
      end
    end
  end
end
