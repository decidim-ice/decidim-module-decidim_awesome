# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CustomRedirectForm < Decidim::Form
        include Decidim::TranslatableAttributes
        attribute :origin, String
        attribute :destination, String
        attribute :active, Boolean
        attribute :pass_query, Boolean

        validates :origin, :destination, presence: true

        def to_params
          [
            sanitize_url(origin),
            {
              destination: sanitize_url(destination, strip_host: false),
              active: active,
              pass_query: pass_query
            }
          ]
        end

        def sanitize_url(url, strip_host: true)
          url = url.strip.downcase
          parsed = Addressable::URI.parse(url)
          url = parsed.path if strip_host && parsed.host == current_organization.host
          url = "/#{url}" unless url.match?(%r{^https?://|^/})
          url
        end
      end
    end
  end
end
