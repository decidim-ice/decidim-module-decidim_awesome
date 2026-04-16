# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class AutoModerationRulesForm < Decidim::Form
        include Decidim::TranslatableAttributes

        translatable_attribute :description, String
        attribute :rule_type, String
        attribute :rule_options, Hash, default: {}
        attribute :targets, Array, default: []
        attribute :enabled, Boolean, default: true

        validates :description, presence: true
        # validates :rule_type, presence: true

        def to_params
          {
            "description" => description,
            # "rule_type" => rule_type,
            # "rule_options" => rule_options,
            # "targets" => targets,
            "enabled" => enabled
          }
        end
      end
    end
  end
end
