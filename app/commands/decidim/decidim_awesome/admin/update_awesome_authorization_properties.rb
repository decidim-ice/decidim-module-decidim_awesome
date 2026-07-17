# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class UpdateAwesomeAuthorizationProperties < Command
        # Public: Initializes the command.
        #
        # form - A AwesomeAuthorizationPropertiesForm form
        def initialize(form)
          @form = form
        end

        attr_reader :form

        def call
          return broadcast(:invalid, form.errors.full_messages.join("; ")) if form.invalid?

          config = Decidim::DecidimAwesome::AwesomeConfig.find_or_initialize_by(var: :awesome_authorization_handler, organization: form.current_organization)

          if form.empty?
            config.destroy! if config.persisted?
          else
            config.value = {
              name: form.name,
              explanation: form.explanation
            }
            config.save!
          end

          broadcast(:ok)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end
      end
    end
  end
end
