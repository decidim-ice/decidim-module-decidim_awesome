# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class UpdateCookieItem < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # category_slug - The slug of the category where the item belongs.
        # item_name - The original name of the item to update.
        # store - An instance of CookieManagementStore to access the categories and items.
        def initialize(form, category_slug)
          @form = form
          @category_slug = category_slug
          @config = AwesomeConfig.find_or_initialize_by(organization: form.current_organization, var: :cookie_management)
        end

        attr_reader :form, :category_slug, :item_name, :config

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form is invalid, category/item not found, or name already exists.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          config.value ||= {}
          config.value[category_slug] ||= {}
          config.value[category_slug]["items"] ||= {}
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
