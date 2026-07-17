# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class SyncAwesomeAuthorizationGroupJob < ApplicationJob
      queue_as :default

      def perform(authorization_group_id)
        authorization_group = Decidim::DecidimAwesome::AuthorizationGroup.find_by(id: authorization_group_id)
        return unless authorization_group

        # clean up authorizations for users that are no longer members of the group
        (authorization_group.granted_in_group + authorization_group.users).each do |user|
          Decidim::DecidimAwesome::AuthorizationGroup.sync_user_authorization(user)
        end
      end
    end
  end
end
