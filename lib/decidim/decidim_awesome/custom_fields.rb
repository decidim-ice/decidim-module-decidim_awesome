# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class CustomFields
      def initialize(fields)
        @fields = if fields.respond_to? :map
                    fields.map { |f| JSON.parse(f) }.flatten
                  else
                    JSON.parse(fields)
                  end
      end

      attr_reader :fields, :xml, :errors

      def apply_xml(xml)
        @xml = Hash.from_xml(xml)
        data = @xml&.dig("xml", "dl", "dd")
        if data.blank?
          @errors = "DL/DD elements not found in the XML"
          return
        end

        data = [data] unless data.is_a?(Array)

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
