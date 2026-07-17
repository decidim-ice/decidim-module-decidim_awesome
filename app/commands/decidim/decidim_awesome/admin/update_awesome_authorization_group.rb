# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class UpdateAwesomeAuthorizationGroup < Command
        # Public: Initializes the command.
        #
        # form - The form object with the authorization group data
        # authorization_group - The authorization group to update
        def initialize(form, authorization_group)
          @form = form
          @authorization_group = authorization_group
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid, form.errors.full_messages.join("; ")) if form.invalid?

          update_authorization_group!

          broadcast(:ok, authorization_group)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :form, :authorization_group

        def update_authorization_group!
          authorization_group.update!(
            name: form.name,
            purpose: form.purpose
          )
        end
      end
    end
  end
end
