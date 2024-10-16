# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CreateScopedStyle < Command
        # Public: Initializes the command.
        #
        def initialize(organization, config_var = :scoped_styles)
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
          styles = AwesomeConfig.find_or_initialize_by(var: @config_var, organization: @organization)
          styles.value = {} unless styles.value.is_a? Hash
          # TODO: prevent (unlikely) colisions with exisiting values
          styles.value[@ident] = ""
          styles.save!

          broadcast(:ok, @ident)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end
      end
    end
  end
end
