# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class DestroyConstraint < Command
        include NeedsConstraintHelpers

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
          return broadcast(:invalid, I18n.t("cannot_be_destroyed", scope: "decidim.decidim_awesome.admin.config.constraints")) unless constraint_can_be_destroyed?(constraint)

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
