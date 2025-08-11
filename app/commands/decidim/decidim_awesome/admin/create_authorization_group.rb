# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CreateAuthorizationGroup < Command
        include NeedsConstraintHelpers
        # Public: Initializes the command.
        #
        def initialize(organization, config_var = :authorization_groups)
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
          groups = AwesomeConfig.find_or_initialize_by(var: @config_var, organization: @organization)
          groups.value ||= {}
          groups.value[@ident] = attributes.deep_dup
          groups.save!

          create_constraint_never(:authorization_group)

          broadcast(:ok, @ident)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        def attributes
          {
            "authorization_handlers" => {},
            "force_authorization_with_any_method" => false,
            "force_authorization_help_text" => {}
          }
        end
      end
    end
  end
end
