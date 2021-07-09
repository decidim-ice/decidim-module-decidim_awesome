# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class DestroyScopedAdmin < Rectify::Command
        # Public: Initializes the command.
        #
        # key - the key to destroy inside scoped_admins
        # organization
        def initialize(key, organization)
          @key = key
          @organization = organization
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if we couldn't proceed.
        #
        # Returns nothing.
        def call
          admins = AwesomeConfig.find_by(var: :scoped_admins, organization: @organization)
          return broadcast(:invalid, "Not a hash") unless admins&.value.is_a? Hash
          return broadcast(:invalid, "#{key} key invalid") unless admins.value.has_key?(@key)

          admins.value.except!(@key)
          admins.save!
          # remove constrains associated (a new config var is generated automatically, by removing it, it will trigger destroy on dependents)
          constraint = AwesomeConfig.find_by(var: "scoped_admin_#{@key}", organization: @organization)
          constraint.destroy! if constraint.present?

          broadcast(:ok, @key)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end
      end
    end
  end
end
