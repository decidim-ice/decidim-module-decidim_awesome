# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module MenuItemsParser
      SAFE_URL_PATTERN = %r{\A(#[\w-]+|/(?!/)\S*|https://\S+)\z}i

      # Parses a JSON string of menu items into an array of hashes.
      # Returns [] on blank input or parse errors.
      def self.parse_json(raw)
        return [] if raw.blank?

        items = JSON.parse(raw)
        return [] unless items.is_a?(Array)

        items
      rescue JSON::ParserError
        []
      end
    end
  end
end
