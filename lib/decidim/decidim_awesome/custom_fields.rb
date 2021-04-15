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
        map_fields! parse_xml(xml)
      rescue StandardError => e
        @errors = e.message
      end

      def to_json(*_args)
        @fields
      end

      private

      def parse_xml(xml)
        @xml = ActiveSupport::XmlMini.parse(xml)
        data = @xml&.dig("xml", "dl", "dd")
        if data.blank?
          @errors = "DL/DD elements not found in the XML"
          return
        end

        data.is_a?(Array) ? data : [data]
      end

      def map_fields!(data)
        return unless data

        @fields.map! do |field|
          value = data.find { |d| d["id"] == field["name"] }.try(:dig, "div")
          value = [value] unless value.blank? || value.is_a?(Array)
          if value.present?
            content = value.map { |v| v["alt"].presence || v["__content__"] }
            field["userData"] = content if content
          end
          field
        end
      end
    end
  end
end
