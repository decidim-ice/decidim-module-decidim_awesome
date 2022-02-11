# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CustomRedirectForm < Decidim::Form
        include Decidim::TranslatableAttributes
        attribute :origin, String
        attribute :destination, String
        attribute :active, Boolean

        validates :origin, :destination, presence: true

        def to_params
          [
            sanitize_origin(origin),
            {
              destination: destination,
              active: active
            }
          ]
        end

        def sanitize_origin(origin)
          parsed = Addressable::URI.parse(origin)
          origin = parsed.path if parsed.host == current_organization.host
          origin = "/#{origin}" unless origin.start_with? "/"
          origin
        end
      end
    end
  end
end
