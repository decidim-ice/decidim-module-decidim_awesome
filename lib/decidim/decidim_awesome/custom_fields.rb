# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class CustomFields
      def initialize(fields)
        @fields = fields.map { |f| JSON.parse(f) }.flatten
      end

      attr_reader :fields, :xml

      def apply_xml(xml)
        @xml = Hash.from_xml(xml)
        data = @xml["xml"]["dl"]["dd"]
        @fields.map! do |field|
          value = data.find { |d| d["name"] == field["name"] }
          field["userData"] = value["ul"].values if value
          field
        end
      rescue StandardError
      end

      def to_json(*_args)
        @fields
      end
    end
  end
end
