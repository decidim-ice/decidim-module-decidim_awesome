# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CookieItemForm < Decidim::Form
        include Decidim::TranslatableAttributes

        attribute :name, String
        attribute :type, String, default: "cookie"
        translatable_attribute :service, String
        translatable_attribute :description, String

        validates :name, presence: true
        validates :type, inclusion: { in: ["cookie"] }
        validates :service, translatable_presence: true
        validates :description, translatable_presence: true

        def to_params
          {
            "name" => name,
            "type" => type.presence || "cookie",
            "service" => service,
            "description" => description
          }
        end
      end
    end
  end
end
