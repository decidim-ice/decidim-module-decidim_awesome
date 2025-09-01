# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CreateProposalCustomField < Command
        include NeedsConstraintHelpers

        # Public: Initializes the command.
        #
        def initialize(organization, config_var = :proposal_custom_fields)
          @organization = organization
          @config_var = config_var
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if we couldn't proceed.
        #
        # Returns nothing.
        def call
          create_hash_config!(default_definition)

          create_constraint_never!

          broadcast(:ok, ident)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        def default_definition
          # '[{"type":"textarea","required":true,"label":"Body","className":"form-control","name":"body","subtype":"textarea"}]'
          "[]"
        end
      end
    end
  end
end
