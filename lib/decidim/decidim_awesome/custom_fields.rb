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

        apply_to_first_textarea
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

      # Finds the first textarea and applies non-xml compatible content
      # when textarea has not wysiwyg assigned, strips html
      def apply_to_first_textarea
        # quill editor might leave html traces without any user content
        # so we won't process it if there is no text (html free) result
        text = Nokogiri.HTML(xml).html? ? Nokogiri.HTML(xml).text.strip : text.strip
        return if text.blank?

        textarea = @fields.find { |field| field["type"] == "textarea" }
        @errors = I18n.t(".invalid_xml", scope: "decidim.decidim_awesome.custom_fields.errors")
        return unless textarea

        textarea["userData"] = [textarea["subtype"] == "textarea" ? text : xml]
        @errors = I18n.t(".invalid_fields", scope: "decidim.decidim_awesome.custom_fields.errors", field: textarea["label"] || textarea["name"])
      end

      def translate_values!
        deep_transform_values!(@fields) do |value|
          next value unless value.is_a? String
          next value unless (match = value.match(/^(.*\..*)$/))

          I18n.t(match[1], raise: true)
        rescue I18n::MissingTranslationData
          value
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
