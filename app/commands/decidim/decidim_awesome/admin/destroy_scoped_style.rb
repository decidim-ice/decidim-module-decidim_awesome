# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class DestroyScopedStyle < Command
        # Public: Initializes the command.
        #
        # key - the key to destroy inside scoped_styles/scoped_admin_styles
        # organization
        def initialize(key, organization, config_var = :scoped_styles)
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
          styles = AwesomeConfig.find_by(var: @config_var, organization: @organization)
          return broadcast(:invalid, "Not a hash") unless styles&.value.is_a? Hash
          return broadcast(:invalid, "#{key} key invalid") unless styles.value.has_key?(@key)

          styles.value.except!(@key)
          styles.save!
          # remove constrains associated (a new config var is generated automatically, by removing it, it will trigger destroy on dependents)
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
