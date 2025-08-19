# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class DestroyAuthorizationGroup < Command
        include NeedsConstraintHelpers
        # Public: Initializes the command.
        #
        # key - the key to destroy inside authorization_groups
        # organization - the organization to which the config belongs
        def initialize(key, organization, config_var = :authorization_groups)
          @ident = key
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
          return broadcast(:invalid, "Not a hash") unless find_var&.value.is_a?(Hash)
          return broadcast(:invalid, "#{ident} key invalid") unless find_var.value.has_key?(ident)

          destroy_hash_ident!

          broadcast(:ok, ident)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end
      end
    end
  end
end
