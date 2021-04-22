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

      attr_reader :fields, :xml, :errors, :data

      def apply_xml(xml)
        parse_xml(xml)
        map_fields!
      rescue StandardError => e
        @errors = e.message
      end

      def to_json(*_args)
        @fields
      end

      private

      def parse_xml(xml)
        @xml = xml
        @data = Nokogiri.XML(xml).xpath("//dl/dd")
        return if @data.present?

        # Apply to the first textarea if exists
        name = apply_to_first_textarea
        @errors = if name
                    "Content couldn't be parsed but has been assigned to the field '#{name}'"
                  else
                    "Content couldn't be parsed: DL/DD elements not found in the XML"
                  end
      end

      def map_fields!
        return unless data

        @fields.map! do |field|
          value = data.search("##{field["name"]} div")
          field["userData"] = value.map { |v| v.attribute("alt")&.value || v.inner_html } if value.present?
          field
        end
      end

      def apply_to_first_textarea
        textarea = @fields.find { |field| field["type"] == "textarea" }
        return unless textarea

        textarea["userData"] = [xml]
        textarea["name"]
      end
    end
  end
end
