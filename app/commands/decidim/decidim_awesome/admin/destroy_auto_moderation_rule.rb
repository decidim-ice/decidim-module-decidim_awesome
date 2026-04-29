# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class DestroyAutoModerationRule < Decidim::Command
        include NeedsConstraintHelpers

        # Public: Initializes the command.
        def initialize(rule_id, organization)
          @rule_id = rule_id
          @organization = organization
          @config_var = :auto_moderation_rules
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if we couldn't proceed.
        #
        # Returns nothing   .
        def call
          config = create_hash_config!

          return broadcast(:invalid, "Rule not found") unless config.value.has_key?(rule_id)

          config.value.delete(rule_id)
          config.save!

          broadcast(:ok)
        end

        private

        attr_reader :rule_id
      end
    end
  end
end
