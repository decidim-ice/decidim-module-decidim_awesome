# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class DestroyAuthorizationGroup < Command
        # Public: Initializes the command.
        #
        # key - the key to destroy inside authorization_groups
        # organization - the organization to which the config belongs
        def initialize(key, organization, config_var = :authorization_groups)
          @key = key
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
          groups = AwesomeConfig.find_by(var: @config_var, organization: @organization)
          return broadcast(:invalid, "Not a hash") unless groups&.value.is_a?(Hash)
          return broadcast(:invalid, "#{@key} key invalid") unless groups.value.has_key?(@key)

          groups.value.except!(@key)
          groups.save!

          constraint = :authorization_group
          constraint = AwesomeConfig.find_by(var: "#{constraint}_#{@key}", organization: @organization)
          constraint.destroy! if constraint.present?

          broadcast(:ok, @key)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end
      end
    end
  end
end
