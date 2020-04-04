# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class DestroyConstraint < Rectify::Command
        # Public: Initializes the command.
        #
        # constraint - A constraint constraint
        def initialize(constraint)
          @constraint = constraint
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if we couldn't proceed.
        #
        # Returns nothing.
        def call
          constraint.destroy!
          broadcast(:ok)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        attr_reader :constraint
      end
    end
  end
end
