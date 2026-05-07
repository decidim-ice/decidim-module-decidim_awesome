# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class ModerationExecutionLog < ApplicationRecord
      self.table_name = "decidim_awesome_moderation_execution_logs"

      belongs_to :organization,
                 foreign_key: "decidim_organization_id",
                 class_name: "Decidim::Organization"
      belongs_to :resource, polymorphic: true
    end
  end
end
