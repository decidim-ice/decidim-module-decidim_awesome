# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CreateScopedAdmin < Rectify::Command
        include NeedsConstraintHelpers

        # Public: Initializes the command.
        #
        def initialize(organization)
          @organization = organization
          @ident = rand(36**8).to_s(36)
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if we couldn't proceed.
        #
        # Returns nothing.
        def call
          admins = AwesomeConfig.find_or_initialize_by(var: :scoped_admins, organization: @organization)
          admins.value = {} unless admins.value.is_a? Hash
          # TODO: prevent (unlikely) colisions with exisiting values
          admins.value[@ident] = []
          admins.save!

          create_constraint_never(:scoped_admin)

          broadcast(:ok, @ident)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end
      end
    end
  end
end
