# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class UpdateCookieCategory < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # config - The AwesomeConfig instance for cookie management.
        def initialize(form)
          @form = form
          @config = AwesomeConfig.find_or_initialize_by(organization: form.current_organization, var: :cookie_management)
        end

        attr_reader :form, :config

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form is invalid, category not found, or slug already exists.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          config.value ||= {}
          # Handle slug change by deleting old key
          config.value[form.slug] = config.value.delete(form.id) if form.id && form.slug != form.id
          config.value[form.slug] = form.to_params.merge("items" => items)
          config.save!

          broadcast(:ok)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        def items
          return {} unless config&.value

          config.value.dig(form.slug, "items") || {}
        end
      end
    end
  end
end
