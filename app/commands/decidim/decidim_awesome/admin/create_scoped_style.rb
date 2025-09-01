# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CreateScopedStyle < Command
        include NeedsConstraintHelpers
        # Public: Initializes the command.
        #
        def initialize(organization, config_var = :scoped_styles)
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
          create_hash_config!("")

          broadcast(:ok, ident)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end
      end
    end
  end
end
