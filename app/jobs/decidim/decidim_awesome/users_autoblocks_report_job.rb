# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class UsersAutoblocksReportJob < ApplicationJob
      queue_as :user_report

      def perform(admin, blocked_user_ids)
        UsersAutoblocksReportMailer.notify(admin, blocked_user_ids).deliver_now
      end
    end
  end
end
