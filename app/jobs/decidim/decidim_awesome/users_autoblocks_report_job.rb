# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class UsersAutoblocksReportJob < ApplicationJob
      queue_as :user_report

      def perform(admin, detected_user_ids, block_performed: true)
        UsersAutoblocksReportMailer.notify(admin, detected_user_ids, block_performed:).deliver_now
      end
    end
  end
end
