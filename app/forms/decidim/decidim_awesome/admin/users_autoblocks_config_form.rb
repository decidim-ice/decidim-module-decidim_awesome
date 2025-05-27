# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class UsersAutoblocksConfigForm < Decidim::Form
        include Decidim::TranslatableAttributes

        DEFAULT_BLOCK_JUSTIFICATION_MESSAGE = "Account blocked automatically"

        attribute :threshold, Integer
        attribute :block_justification_message, String
        attribute :notify_blocked_users, Boolean, default: false
        attribute :perform_block, Boolean, default: false
        attribute :allow_performing_block_from_a_task, Boolean, default: false

        validates :threshold, presence: true
        validates :block_justification_message, presence: true, length: { minimum: UserBlock::MINIMUM_JUSTIFICATION_LENGTH }, if: ->(form) { form.perform_block && form.notify_blocked_users }

        def to_params
          {
            threshold:,
            block_justification_message:,
            notify_blocked_users:,
            allow_performing_block_from_a_task:
          }
        end

        def default_block_justification_message
          DEFAULT_BLOCK_JUSTIFICATION_MESSAGE
        end
      end
    end
  end
end
