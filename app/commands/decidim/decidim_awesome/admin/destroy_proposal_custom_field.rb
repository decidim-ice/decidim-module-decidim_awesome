# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class DestroyProposalCustomField < Command
        # Public: Initializes the command.
        #
        # key - the key to destroy inise proposal_custom_fields
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
          private_fields = AwesomeConfig.find_by(var: :private_proposal_custom_fields, organization: @organization)
          fields = AwesomeConfig.find_by(var: :proposal_custom_fields, organization: @organization)
          return broadcast(:invalid, "Not a hash") unless fields&.value.is_a? Hash
          return broadcast(:invalid, "#{key} key invalid") unless fields.value.has_key?(@key)

          fields.value.except!(@key)
          fields.save!

          if private_fields
            private_fields.value.except!(@key)
            private_fields.save!
          end

          # remove constrains associated (a new config var is generated automatically, by removing it, it will trigger destroy on dependents)
          constraint = AwesomeConfig.find_by(var: "proposal_custom_field_#{@key}", organization: @organization)
          constraint.destroy! if constraint.present?

          broadcast(:ok, @key)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end
      end
    end
  end
end
