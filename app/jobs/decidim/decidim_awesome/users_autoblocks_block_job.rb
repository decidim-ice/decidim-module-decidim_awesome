# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class UsersAutoblocksBlockJob < ApplicationJob
      queue_as :default

      def perform(admin, perform_block: nil)
        config = AwesomeConfig.find_or_initialize_by(
          var: :users_autoblocks_config,
          organization: admin.organization
        )

        perform_block = if perform_block.nil?
                          true
                        else
                          perform_block
                        end

        command = Decidim::DecidimAwesome::Admin::AutoblockUsers.new(
          admin.organization,
          admin,
          perform_block: perform_block
        )

        command.call do
          on(:ok) do |count, block_performed|
          end
          on(:invalid) do |error|
            @result = { error: }
            handle_result(result)
          end
        end
      end

      private

      def handle_result(result)
        if result[:error]
          Rails.logger.error("AutoblockUsers failed: #{result[:error]}")
        elsif result[:block_performed]
          Rails.logger.info("AutoblockUsers blocked #{result[:count]} users")
        else
          Rails.logger.info("AutoblockUsers calculated scores for #{result[:count]} users")
        end
      end
    end
  end
end
