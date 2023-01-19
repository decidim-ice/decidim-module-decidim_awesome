# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class ConfigConstraint < ApplicationRecord
      self.table_name = "decidim_awesome_config_constraints"

      belongs_to :awesome_config, foreign_key: :decidim_awesome_config_id, class_name: "Decidim::DecidimAwesome::AwesomeConfig"
    end
  end
end
