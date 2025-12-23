# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class DestroyUsersAutoblockRule < Command
        # Public: Initializes the command.
        #
        def initialize(rule, organization)
          @rule = rule
          @users_autoblocks = AwesomeConfig.find_or_initialize_by(var: :users_autoblocks, organization:)
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless rule_exists?

          users_autoblocks.value.delete_if { |r| r["id"] == rule.id }
          users_autoblocks.save!
          broadcast(:ok, rule)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :rule, :users_autoblocks

        def rule_exists?
          return unless users_autoblocks&.value.is_a?(Array)

          users_autoblocks.value.find { |r| r["id"] == rule.id }.present?
        end
      end
    end
  end
end
