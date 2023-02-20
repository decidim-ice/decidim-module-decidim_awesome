# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class ExportAdminActionsJob < ApplicationJob
      queue_as :default

      def perform(current_user, format, collection_ids)
        collection = serialized_collection(collection_ids)

        export_data = Exporters.find_exporter(format).new(collection).export

        ExportMailer.export(current_user, "admin_actions", export_data).deliver_now
      end

      private

      def serialized_collection(collection_ids)
        @serialized_collection ||= begin
          collection = PaperTrailVersion.where(id: collection_ids)
          collection.map do |item|
            PaperTrailVersionSerializer.new(item).serialize
          end
        end
      end
    end
  end
end
