# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class UsersAutoblocksConfigForm < Decidim::Form
        include Decidim::TranslatableAttributes

        attribute :threshold, Integer
        attribute :block_justification_message, String
        attribute :notify_blocked_users, Boolean, default: false
        attribute :perform_block, Boolean, default: false
        attribute :allow_performing_block_from_a_task, Boolean, default: false

        validates :threshold, presence: true
        validates(
          :block_justification_message,
          presence: true,
          length: { minimum: UserBlock::MINIMUM_JUSTIFICATION_LENGTH },
          if: ->(form) { form.perform_block && form.notify_blocked_users }
        )

        def to_params
          {
            threshold:,
            block_justification_message:,
            notify_blocked_users:,
            allow_performing_block_from_a_task:
          }.merge(current_admin_params)
        end

        def default_block_justification_message
          I18n.t("decidim.decidim_awesome.admin.config.users_autoblocks.config_form.default_block_justification_message")
        end

        def current_admin_params
          return {} unless allow_performing_block_from_a_task

          { admin_id: current_user.id }
        end
      end
    end
  end
end
