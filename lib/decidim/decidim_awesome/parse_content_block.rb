# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class ParseContentBlock
      def initialize(cell)
        @cell = cell
        # Force the cell to render any missing method to empty content
        def cell.method_missing(name, *, &)
          "{missing method #{name}}"
        end

        def cell.respond_to_missing?(_name, *)
          true
        end
      end

      attr_reader :cell

      def id
        @id ||= begin
          Nokogiri::HTML::DocumentFragment.parse(cell.call).css("[id]").first&.attribute("id")&.value
        rescue StandardError
          nil
        end
      end
    end
  end
end
