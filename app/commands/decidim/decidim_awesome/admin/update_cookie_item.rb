# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class UpdateCookieItem < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # category_slug - The slug of the category where the item belongs.
        # config - The AwesomeConfig instance for cookie management.
        def initialize(form, category_slug)
          @form = form
          @category_slug = category_slug
          @config = AwesomeConfig.find_or_initialize_by(organization: form.current_organization, var: :cookie_management)
        end

        attr_reader :form, :category_slug, :config

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form is invalid, category/item not found, or name already exists.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          config.value ||= {}
          config.value[category_slug] ||= { "slug" => category_slug, "items" => {} }

          config.value[category_slug]["items"] ||= {}
          # Handle slug change by deleting old key
          config.value[category_slug]["items"][form.name] = config.value[category_slug]["items"].delete(form.id) if form.id && form.name != form.id
          config.value[category_slug]["items"][form.name] = form.to_params
          config.save!

          broadcast(:ok)
        rescue ActiveRecord::RecordInvalid => e
          broadcast(:invalid, e.record.errors.full_messages.join(", "))
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end
      end
    end
  end
end
