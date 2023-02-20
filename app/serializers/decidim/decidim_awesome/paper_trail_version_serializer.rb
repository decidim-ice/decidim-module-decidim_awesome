# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # This class serializes a AdminAccountability so can be exported to CSV, JSON or other
    # formats.
    class PaperTrailVersionSerializer < Decidim::Exporters::Serializer
      include Decidim::ApplicationHelper
      include Decidim::ResourceHelper
      include Decidim::TranslationsHelper

      # Public: Initializes the serializer with a admin actions.
      def initialize(log_entry)
        @entry = log_entry.present(html: false)
      end

      # Public: Exports a hash with the serialized data for this admin action.
      def serialize
        {
          role: entry.role_name,
          user_name: entry.user_name,
          user_email: entry.user_email,
          user_role_type: entry.entry.item_type,
          participatory_space_type: entry.participatory_space_type,
          participatory_space_title: translated_attribute(entry.participatory_space&.title),
          last_sign_in_at: entry.last_sign_in_date,
          role_created_at: entry.created_date,
          role_removed_at: entry.removal_date
        }
      end

      private

      attr_reader :entry
    end
  end
end
