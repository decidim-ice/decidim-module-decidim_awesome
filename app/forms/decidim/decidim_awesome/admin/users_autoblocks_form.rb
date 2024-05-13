# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class UsersAutoblocksForm < Decidim::Form
        attribute :type, String
        attribute :weight, Integer, default: "1"
        attribute :allowlist, String
        attribute :blocklist, String
        attribute :block_if_detected, Boolean, default: true
        attribute :enabled, Boolean, default: true

        validates :type, inclusion: { in: Decidim::DecidimAwesome::UserAutoblockScoresPresenter::USERS_AUTOBLOCKS_TYPES.keys }
        validates :weight, presence: true

        def to_params
          {
            type:,
            weight:,
            allowlist:,
            blocklist:,
            block_if_detected:,
            enabled:
          }
        end
      end
    end
  end
end
