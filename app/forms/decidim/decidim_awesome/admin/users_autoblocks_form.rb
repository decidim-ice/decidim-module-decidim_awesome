# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class UsersAutoblocksForm < Decidim::Form
        attribute :application_type, String
        attribute :type, String
        attribute :weight, Integer, default: "1"
        attribute :allowlist, String
        attribute :blocklist, String

        validates :type, inclusion: { in: Decidim::DecidimAwesome::UserAutoblockScoresPresenter::USERS_AUTOBLOCKS_TYPES.keys }
        validates :application_type, :type, :weight, presence: true

        def to_params
          {
            application_type:,
            type:,
            weight:,
            allowlist:,
            blocklist:
          }
        end
      end
    end
  end
end
