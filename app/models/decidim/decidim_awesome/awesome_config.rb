# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class AwesomeConfig < ApplicationRecord
      self.table_name = "decidim_awesome_config"

      belongs_to :organization, foreign_key: :decidim_organization_id, class_name: "Decidim::Organization"

      validates :organization, presence: true
      validates :var, uniqueness: { scope: :decidim_organization_id }

      # obtains all configured variables for an organization
      def self.organization_config(organization)
        where(organization: organization).all.map { |v| [v.var.to_sym, v.value] }.to_h
      end

      # obtains all variables for an organization, normalizes with defaults in case of missing
      def self.config_for(organization)
        config = organization_config(organization)
        DecidimAwesome.config.map do |key, val|
          [key, config[key].presence || val]
        end.to_h
      end
    end
  end
end
