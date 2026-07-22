# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class FollowUpQuestionnaryForm < Decidim::Form
        include Decidim::TranslatableAttributes

        translatable_attribute :name, String
        attribute :participatory_space_name, String
        attribute :position, Integer
        attribute :responder_email, String
        attribute :responder_name, String
        attribute :status, String, default: "pending"
        attribute :submission_date, DateTime
        attribute :questionnary_id, Integer

        validates :name, translatable_presence: true
      end
    end
  end
end
