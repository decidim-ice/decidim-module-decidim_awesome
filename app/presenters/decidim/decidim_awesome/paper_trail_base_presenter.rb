# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class PaperTrailBasePresenter
      attr_reader :entry, :html

      def initialize(entry, html: true)
        @entry = entry
        @html = html
      end

      # try to use the object in the database if exists
      # Note that "reify" does not work on "create" events
      def item
        @item ||= entry&.item
      end

      def item_type
        @item_type ||= entry&.item_type
      end

      def item_id
        @item_id ||= entry&.item_id
      end
    end
  end
end
