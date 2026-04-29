# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # Describes a moderation rule type that can be registered and applied to content objects.
    # Each manifest declares what object types the rule supports and points to the
    # checker class that performs the actual evaluation.
    #
    # Register a rule with:
    #   Decidim::DecidimAwesome.moderation_rules_registry.register(:word_filter) do |rule|
    #     rule.checker_class = "Decidim::DecidimAwesome::ModerationRules::WordFilterRule"
    #     rule.form_class    = "Decidim::DecidimAwesome::Admin::WordFilterRuleForm"
    #     rule.supported_object_types = [:proposals, :comments]
    #   end
    class ModerationRuleManifest
      include ActiveModel::Model
      include Decidim::AttributeObject::Model

      # Symbol identifier, must be unique across the registry (e.g. :word_filter)
      attribute :name, Symbol

      # Fully-qualified class name of the admin form used to configure rule options.
      # Optional: leave nil if the rule needs no configuration.
      attribute :form_class, String, default: nil

      # Fully-qualified class name of the checker.
      # The class must respond to:
      #   #check(object, options, context = {}) → true | false
      # Optionally:
      #   #applies_to?(object) → true | false  (runtime guard)
      attribute :checker_class, String

      # Array of symbols identifying which Decidim object types this rule can evaluate.
      # Supported values depend on what hooks/overrides are wired, e.g.:
      #   [:proposals, :comments]
      attribute :supported_object_types, Array, default: []

      attribute :name_key, String
      attribute :description_key, String

      validates :name, :name_key, :description_key, presence: true
      validates :checker_class, presence: true
    end
  end
end
