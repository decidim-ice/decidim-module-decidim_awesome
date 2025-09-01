# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CreateScopedAdmin < Command
        include NeedsConstraintHelpers

        # Public: Initializes the command.
        #
        def initialize(organization)
          @organization = organization
          @config_var = :scoped_admins
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if we couldn't proceed.
        #
        # Returns nothing.
        def call
          create_hash_config!([])

          create_constraint_never!

          broadcast(:ok, ident)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end
      end
    end
  end
end
