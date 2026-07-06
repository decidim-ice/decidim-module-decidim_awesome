# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CreateAwesomeAuthorizationGroup < Command
        # Public: Initializes the command.
        #
        # form - The form object with the authorization group data
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid, form.errors.full_messages.join("; ")) if form.invalid?

          create_authorization_group!

          broadcast(:ok, authorization_group)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :form, :authorization_group

        def create_authorization_group!
          @authorization_group = form.current_organization.awesome_authorization_groups.create!(
            name: form.name,
            purpose: form.purpose
          )
        end
      end
    end
  end
end
