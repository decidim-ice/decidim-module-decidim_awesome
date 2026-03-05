# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CreateCookieItemPreset < Decidim::Command
        # Public: Initializes the command.
        #
        # forms - An array of CookieItemForm objects to create.
        # category_slug - The slug of the category where the items will be created.
        def initialize(forms, category_slug)
          @forms = forms
          @category_slug = category_slug
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when all items were created (skipping duplicates).
        # - :invalid if any item fails validation or an unexpected error occurs.
        #
        # Returns nothing.
        def call
          errors = []

          forms.each do |form|
            CreateCookieItem.call(form, category_slug) do
              on(:invalid) do |error_message|
                errors << "#{form.name}: #{error_message.presence || form.errors.full_messages.join(", ")}"
              end
            end
          end

          return broadcast(:invalid, errors.join(" | ")) if errors.any?

          broadcast(:ok)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :forms, :category_slug
      end
    end
  end
end
