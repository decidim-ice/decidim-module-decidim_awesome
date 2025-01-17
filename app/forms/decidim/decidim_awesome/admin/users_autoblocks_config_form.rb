# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class UsersAutoblocksConfigForm < Decidim::Form
        include Decidim::TranslatableAttributes

        attribute :threshold, Integer
        attribute :block_justification_message, String
        attribute :perform_block, Boolean, default: false

        validates :threshold, presence: true
        validates :block_justification_message, presence: true, length: { minimum: UserBlock::MINIMUM_JUSTIFICATION_LENGTH }, if: ->(form) { form.perform_block }

        def to_params
          {
            threshold:,
            block_justification_message:
          }
        end
      end
    end
  end
end
