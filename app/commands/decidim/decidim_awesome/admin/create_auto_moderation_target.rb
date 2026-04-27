# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CreateAutoModerationTarget < Decidim::Command
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
          if config.value[rule_id].nil?
            raise ActiveRecord::RecordNotFound
          end

          rule_config = config.value[rule_id] || {}
          targets = rule_config["targets"] || {}
          target_entry = form.to_params

          targets[ident] = target_entry
          rule_config["targets"] = targets
          config.value[rule_id] = rule_config
          config.save!
          broadcast(:ok, target_entry)
        end

        attr_reader :form, :rule_id
      end
    end
  end
end
