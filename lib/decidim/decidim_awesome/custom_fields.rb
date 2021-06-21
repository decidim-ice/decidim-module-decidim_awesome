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

      def translate!
        translate_values!
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
          if field["name"] # ignore headers/paragraphs
            value = data.search("##{field["name"]} div")
            field["userData"] = value.map { |v| v.attribute("alt")&.value || v.inner_html(encoding: "UTF-8") } if value.present?
          end

          field
        end
      end

      def apply_to_first_textarea
        textarea = @fields.find { |field| field["type"] == "textarea" }
        return unless textarea

        textarea["userData"] = [xml]
        textarea["name"]
      end

      def translate_values!
        deep_transform_values!(@fields) do |value|
          next value unless value.is_a? String
          next value unless (match = value.match(/^(.*\..*)$/))

          I18n.t(match[1])
        end
        @fields
      end

      def deep_transform_values!(object, &block)
        case object
        when Hash
          object.transform_values! { |value| deep_transform_values!(value, &block) }
        when Array
          object.map! { |e| deep_transform_values!(e, &block) }
        else
          yield(object)
        end
      end
    end
  end
end
