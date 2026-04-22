# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class AutoModerationRulesForm < Decidim::Form
        include Decidim::TranslatableAttributes

        translatable_attribute :description, String
        attribute :rule_type, String
        attribute :rule_options, String, default: ""
        attribute :targets, Hash, default: []
        attribute :enabled, Boolean, default: true
        attribute :counter, Integer, default: 0

        validates :description, presence: true
        validates :rule_type, presence: true
        validates :rule_type, inclusion: { in: Decidim::DecidimAwesome.moderation_rules_registry.manifests.map(&:name).map(&:to_s) }, if: -> { rule_type.present? }

        def to_params
          {
            "description" => description,
            "rule_type" => rule_type,
            "rule_options" => rule_options,
            "targets" => targets,
            "enabled" => enabled,
            "counter" => counter
          }
        end
      end
    end
  end
end
