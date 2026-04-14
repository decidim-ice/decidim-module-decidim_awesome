# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # Describes a moderation action type that can be registered and applied when a rule matches.
    # Each manifest declares what object types the action supports and points to the
    # handler class that performs the side effect (e.g. hiding content).
    #
    # Register an action with:
    #   Decidim::DecidimAwesome.moderation_actions_registry.register(:moderate_and_hide) do |action|
    #     action.handler_class = "Decidim::DecidimAwesome::ModerationActions::ModerateAndHideAction"
    #     action.supported_object_types = [:proposals, :comments]
    #   end
    class ModerationActionManifest
      include ActiveModel::Model
      include Decidim::AttributeObject::Model

      # Symbol identifier, must be unique across the registry (e.g. :moderate_and_hide)
      attribute :name, Symbol

      # Fully-qualified class name of the admin form used to configure action options.
      # Optional: leave nil if the action needs no configuration.
      attribute :form_class, String, default: nil

      # Fully-qualified class name of the handler.
      # The class must respond to:
      #   #apply(object, options, context = {}) → { success: true|false, message: String }
      # Optionally:
      #   #applies_to?(object) → true | false  (runtime guard, e.g. skip already-hidden)
      attribute :handler_class, String

      # Array of symbols identifying which Decidim object types this action can be applied to.
      # Supported values depend on what hooks/overrides are wired, e.g.:
      #   [:proposals, :comments]
      attribute :supported_object_types, Array, default: []

      validates :name, presence: true
      validates :handler_class, presence: true
    end
  end
end
