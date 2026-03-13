# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class UpdateCookieCategory < Decidim::Command
        include NeedsAwesomeConfig

        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # category_slug - The original slug of the category to update.
        # store - An instance of CookieManagementStore to access the categories.
        def initialize(form, category_slug)
          @form = form
          @category_slug = category_slug
          config = AwesomeConfig.find_by(organization: form.current_organization, var: :cookie_management)
          @store = CookieManagementStore.new(form.current_organization, config&.value)
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form is invalid, category not found, or slug already exists.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?
          return broadcast(:invalid) unless find_category

          update_category
          @store.save!(@store.stored_categories)

          broadcast(:ok)
        rescue ActiveRecord::RecordInvalid => e
          broadcast(:invalid, e.record.errors.full_messages.join(", "))
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :form, :category_slug

        def find_category
          @category = @store.find_category(category_slug)

          if @category.nil?
            form.errors.add(:base, :not_found)
            return false
          end

          @category_index = @store.stored_categories.index { |c| c["slug"].to_s == @category.slug.to_s }
          true
        end

        def update_category
          updated = form.to_params
          updated["slug"] = category_slug

          if @category_index.nil?
            updated["items"] = []
            @store.stored_categories << updated
          else
            stored = @store.stored_categories[@category_index]
            items = stored["items"].is_a?(Array) ? stored["items"] : []
            updated["items"] = items
            @store.stored_categories[@category_index] = updated
          end
        end
      end
    end
  end
end
