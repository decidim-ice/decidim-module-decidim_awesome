# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CreateAutoModerationRule < Decidim::Command
        include NeedsConstraintHelpers

        # Public: Initializes the command.
        def initialize(form, organization)
          @form = form
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
          entry = form.to_params

          config.value[ident] = entry
          config.save!
          broadcast(:ok, entry)
        end

        private

        attr_reader :form
      end
    end
  end
end
