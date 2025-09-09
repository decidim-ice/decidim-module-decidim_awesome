# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class ExportAdminActionsJob < ApplicationJob
      include Decidim::PrivateDownloadHelper

      queue_as :default

      def perform(current_user, format, collection_ids)
        collection = serialized_collection(collection_ids)

        export_data = Decidim::Exporters.find_exporter(format).new(collection).export

        private_export = attach_archive(export_data, "admin_actions", current_user)

        ExportMailer.export(current_user, private_export).deliver_now
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
