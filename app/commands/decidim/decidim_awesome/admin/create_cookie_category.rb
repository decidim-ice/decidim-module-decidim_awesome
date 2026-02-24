# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CreateCookieCategory < Decidim::Command
        include NeedsAwesomeConfig

        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form is invalid or slug already exists.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?
          return broadcast(:invalid) if duplicate_slug?

          add_category
          save_categories!

          broadcast(:ok)
        rescue ActiveRecord::RecordInvalid => e
          broadcast(:invalid, e.record.errors.full_messages.join(", "))
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :form

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

        def duplicate_slug?
          if current_categories.any? { |c| c["slug"].to_s == form.slug }
            form.errors.add(:slug, :taken)
            return true
          end
          false
        end

        def add_category
          current_categories << form.to_params
        end

        def save_categories!
          cookie_management_setting.value = categories_data
          cookie_management_setting.save!
        end
      end
    end
  end
end
