# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CreateCookieItem < Decidim::Command
        include NeedsAwesomeConfig

        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # category_slug - The slug of the category where the item will be created.
        def initialize(form, category_slug)
          @form = form
          @category_slug = category_slug
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form is invalid, category doesn't exist, or name already exists.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?
          return broadcast(:invalid) unless find_category
          return broadcast(:invalid) if duplicate_item_name?

          add_item_to_category
          save_cookie_management!

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

        def find_category
          @category = categories_data["categories"].find { |c| c["slug"].to_s == category_slug.to_s }

          unless @category
            form.errors.add(:base, :category_not_found)
            return false
          end

          @category["items"] = [] unless @category["items"].is_a?(Array)
          true
        end

        def duplicate_item_name?
          if @category["items"].any? { |i| i["name"].to_s == form.name }
            form.errors.add(:name, :taken)
            return true
          end
          false
        end

        def add_item_to_category
          @category["items"] << form.to_params
        end

        def save_cookie_management!
          cookie_management_setting.value = categories_data
          cookie_management_setting.save!
        end
      end
    end
  end
end
