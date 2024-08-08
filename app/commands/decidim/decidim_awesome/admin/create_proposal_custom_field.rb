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
          @ident = rand(36**8).to_s(36)
          @config_var = config_var
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if we couldn't proceed.
        #
        # Returns nothing.
        def call
          fields = AwesomeConfig.find_or_initialize_by(var: @config_var, organization: @organization)
          fields.value = {} unless fields.value.is_a? Hash
          # TODO: prevent (unlikely) colisions with exisiting values
          fields.value[@ident] = default_definition
          fields.save!

          create_constraint_never(@config_var == :proposal_custom_fields ? :proposal_custom_field : :proposal_private_custom_field)

          broadcast(:ok, @ident)
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
