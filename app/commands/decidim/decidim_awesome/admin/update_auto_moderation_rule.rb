# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class UpdateAutoModerationRule < Decidim::Command
        include NeedsConstraintHelpers

        # Public: Initializes the command.
        def initialize(form, rule_id, organization)
          @form = form
          @rule_id = rule_id
          @organization = organization
          @config_var = :auto_moderation_rules
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          config = create_hash_config!
          old_entry = config.value[@rule_id]
          target = old_entry["targets"] || {}

          entry = form.to_params
          rule_options = entry.delete("rule_options")
          entry["rule_options"] = rule_options.split(",").map(&:strip).reject(&:empty?)
          entry["targets"] = target

          config.value[@rule_id] = entry
          config.save!
          broadcast(:ok, entry)
        end

        private

        attr_reader :form, :rule_id
      end
    end
  end
    end
