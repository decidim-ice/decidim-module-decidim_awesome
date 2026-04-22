# frozen_string_literal: true

# frozen_string_literal

module Decidim
  module DecidimAwesome
    module Admin
      class UpdateAutoModerationTarget < Decidim::Command
        include NeedsConstraintHelpers

        # Public: Initializes the command.
        def initialize(form, rule_id, target_id, organization)
          @form = form
          @rule_id = rule_id
          @target_id = target_id
          @organization = organization
          @config_var = :auto_moderation_rules
        end

        # Executes the command. Broadcasts these events:
        # - :ok when everything is valid.
        # - :invalid if we couldn't proceed.
        # Returns nothing.
        def call
          return broadcast(:invalid) if @form.invalid?

          config = create_hash_config!
          rule_entry = config.value[@rule_id]
          raise ActiveRecord::RecordNotFound unless rule_entry

          target = rule_entry["targets"] || {}
          entry = @form.to_params

          target_entry = {
            "object_type" => entry.delete("object_type"),
            "action_type" => entry.delete("action_type"),
            "action_options" => entry.delete("action_options")
          }
          target[@target_id] = target_entry

          rule_entry["targets"] = target
          config.value[@rule_id] = rule_entry
          config.save!
          broadcast(:ok, target_entry)
        end
      end
    end
  end
end
