# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class UpdateCookieItem < Decidim::Command
        include NeedsAwesomeConfig
        include HasCookieCategories

        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # category_slug - The slug of the category where the item belongs.
        # item_name - The original name of the item to update.
        def initialize(form, category_slug, item_name)
          @form = form
          @category_slug = category_slug
          @item_name = item_name
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form is invalid, category/item not found, or name already exists.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?
          return broadcast(:invalid) unless find_category
          return broadcast(:invalid) unless find_item
          return broadcast(:invalid) if default_item_name_changed?
          return broadcast(:invalid) if duplicate_item_name?

          update_item
          save_cookie_management!

          broadcast(:ok)
        rescue ActiveRecord::RecordInvalid => e
          broadcast(:invalid, e.record.errors.full_messages.join(", "))
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :form, :category_slug, :item_name

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

        def find_item
          @item_index = @category["items"].index { |i| i["name"].to_s == item_name.to_s }

          if @item_index.nil?
            form.errors.add(:base, :not_found)
            return false
          end

          true
        end

        def default_item_name_changed?
          return false if form.name == item_name
          return false unless default_cookie_item?(category_slug, item_name)

          form.errors.add(:name, :cannot_change_default_item_name)
          true
        end

        def duplicate_item_name?
          return false if form.name == item_name

          if @category["items"].any? { |i| i["name"].to_s == form.name }
            form.errors.add(:name, :taken)
            return true
          end
          false
        end

        def update_item
          @category["items"][@item_index] = form.to_params
        end

        def save_cookie_management!
          cookie_management_setting.value = categories_data
          cookie_management_setting.save!
        end
      end
    end
  end
end
