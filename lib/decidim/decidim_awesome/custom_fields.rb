# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class CustomFields
      def initialize(fields)
        @fields = fields.map { |f| JSON.parse(f) }.flatten
      end

      attr_reader :fields, :xml, :errors

      def apply_xml(xml)
        @xml = Hash.from_xml(xml)
        data = @xml&.dig("xml", "dl", "dd")
        return if data.blank?

        @fields.map! do |field|
          value = data.find { |d| d["id"] == field["name"] }
          if value
            field["userData"] = value["div"].is_a?(Array) ? value["div"] : [value["div"]]
          end
          field
        end
      rescue StandardError => e
        @errors = e.message
      end

      def to_json(*_args)
        @fields
      end
    end
  end
end
