# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CreateAuthorizationGroup < Command
        include NeedsConstraintHelpers
        # Public: Initializes the command.
        #
        def initialize(organization, config_var = :force_authorizations)
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
          create_hash_config!(attributes)

          create_constraint_never!

          broadcast(:ok, ident)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        def attributes
          {
            "authorization_handlers" => {},
            "force_authorization_help_text" => {}
          }
        end
      end
    end
  end
end
