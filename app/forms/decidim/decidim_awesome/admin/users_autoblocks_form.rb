# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class UsersAutoblocksForm < Decidim::Form
        attribute :type, String
        attribute :weight, Integer, default: "1"
        attribute :variable, String
        attribute :blocklist, Boolean, default: true
        attribute :enabled, Boolean, default: true

        validates :type, inclusion: { in: Decidim::DecidimAwesome::UserAutoblockScoresPresenter::USERS_AUTOBLOCKS_TYPES.keys }
        validates :weight, presence: true
        validates :variable, presence: true, if: ->(form) { USERS_AUTOBLOCKS_TYPES[form.type].presence&.dig(:has_variable) }

        def to_params
          {
            type:,
            weight:,
            variable:,
            blocklist:,
            enabled:
          }
        end
      end
    end
  end
end
