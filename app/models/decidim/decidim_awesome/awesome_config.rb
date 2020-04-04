# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class AwesomeConfig < ApplicationRecord
      self.table_name = "decidim_awesome_config"

      belongs_to :organization, foreign_key: :decidim_organization_id, class_name: "Decidim::Organization"

      has_many :constraints,
               foreign_key: "decidim_awesome_config_id",
               class_name: "Decidim::DecidimAwesome::ConfigConstraint",
               dependent: :destroy

      validates :organization, presence: true
      validates :var, uniqueness: { scope: :decidim_organization_id }

      def self.for_organization(organization)
        where(organization: organization)
      end
    end
  end
end
