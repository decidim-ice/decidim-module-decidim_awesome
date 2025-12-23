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

        validates :type, inclusion: { in: -> { Decidim::DecidimAwesome.users_autoblocks_types } }
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
