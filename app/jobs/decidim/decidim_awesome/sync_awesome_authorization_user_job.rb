# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class SyncAwesomeAuthorizationUserJob < ApplicationJob
      queue_as :default

      def perform(user_id)
        user = Decidim::User.find_by(id: user_id)
        return unless user

        Decidim::DecidimAwesome::AuthorizationGroup.sync_user_authorization(user)
      end
    end
  end
end
