# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CookieItemForm < Decidim::Form
        include Decidim::TranslatableAttributes
        ITEM_TYPES = %w(cookie local_storage).freeze

        attribute :name, String
        attribute :type, String, default: "cookie"
        translatable_attribute :service, String
        translatable_attribute :description, String
        translatable_attribute :expiration, String

        validates :name, presence: true
        validates :name, format: {
          with: %r{\A[a-zA-Z0-9_.:\-/]+\z},
          message: :invalid_format
        }
        validates :type, inclusion: { in: ITEM_TYPES }
        validates :service, translatable_presence: true
        validates :description, translatable_presence: true
        def to_params
          {
            "name" => name,
            "type" => type.presence || "cookie",
            "service" => service,
            "description" => description,
            "expiration" => expiration.presence || {}
          }
        end
      end
    end
  end
end
