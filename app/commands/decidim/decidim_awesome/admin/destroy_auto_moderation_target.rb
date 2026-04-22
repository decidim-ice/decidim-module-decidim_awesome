# frozen_string_literal: true

module Decidim
    module DecidimAwesome
        module Admin
            class DestroyAutoModerationTarget < Decidim::Command
                include NeedsConstraintHelpers

                # Public: Initializes the command.
                def initialize(target_id, rule_id, organization)
                    @target_id = target_id
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
                    config = create_hash_config!()
                    return broadcast(:invalid) unless config

                    rule_config = config.value[rule_id]
                    return broadcast(:invalid) unless rule_config

                    targets = rule_config["targets"] || {}
                    return broadcast(:invalid) unless targets[target_id]

                    targets.delete(target_id)
                    rule_config["targets"] = targets
                    config.value[rule_id] = rule_config
                    config.save!
                    broadcast(:ok)
                end

                private

                attr_reader :target_id, :rule_id
            end
        end
    end
end 