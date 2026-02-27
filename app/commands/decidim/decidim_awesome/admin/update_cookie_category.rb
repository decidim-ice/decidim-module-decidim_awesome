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
        def initialize(form, category_slug)
          @form = form
          @category_slug = category_slug
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
          return broadcast(:invalid) if duplicate_slug?

          update_category
          save_categories!

          broadcast(:ok)
        rescue ActiveRecord::RecordInvalid => e
          broadcast(:invalid, e.record.errors.full_messages.join(", "))
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :form, :category_slug

        def cookie_management_setting
          @cookie_management_setting ||= AwesomeConfig.find_or_initialize_by(
            var: :cookie_management,
            organization: form.current_organization
          )
        end

        def categories_data
          @categories_data ||= begin
            data = cookie_management_setting.value
            data = {} unless data.is_a?(Hash)
            data["categories"] = [] unless data["categories"].is_a?(Array)
            data
          end
        end

        def current_categories
          categories_data["categories"]
        end

        def find_category
          @category_index = current_categories.index { |c| c["slug"].to_s == category_slug.to_s }

          unless @category_index
            form.errors.add(:base, :not_found)
            return false
          end

          @category = current_categories[@category_index]
          true
        end

        def duplicate_slug?
          false
        end

        def update_category
          items = @category["items"].is_a?(Array) ? @category["items"] : []
          updated = form.to_params
          updated["slug"] = category_slug
          updated["items"] = items

          current_categories[@category_index] = updated
        end

        def save_categories!
          cookie_management_setting.value = categories_data
          cookie_management_setting.save!
        end
      end
    end
  end
end
