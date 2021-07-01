# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CreateScopedAdmin < Rectify::Command
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

          create_default_constraints

          broadcast(:ok, @ident)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        def create_default_constraints
          settings = { "participatory_space_manifest" => "none" }
          subconfig = AwesomeConfig.find_or_initialize_by(var: "scoped_admin_#{@ident}", organization: @organization)
          @constraint = ConfigConstraint.create!(
            awesome_config: subconfig,
            settings: settings
          )
        end
      end
    end
  end
end
