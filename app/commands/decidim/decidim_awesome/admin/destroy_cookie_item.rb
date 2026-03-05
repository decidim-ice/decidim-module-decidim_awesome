# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class DestroyCookieItem < Decidim::Command
        include NeedsAwesomeConfig
        include HasCookieCategories

        # Public: Initializes the command.
        #
        # category_slug - The slug of the category where the item belongs.
        # item_name - The name of the item to destroy.
        # organization - The organization where the item belongs.
        def initialize(category_slug, item_name, organization)
          @category_slug = category_slug
          @item_name = item_name
          @organization = organization
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the category is not found.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless find_category

          unless remove_item
            broadcast(:invalid)
            return
          end

          save_cookie_management!

          broadcast(:ok)
        rescue ActiveRecord::RecordInvalid => e
          broadcast(:invalid, e.record.errors.full_messages.join(", "))
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :category_slug, :item_name, :organization

        def cookie_management_setting
          @cookie_management_setting ||= AwesomeConfig.find_or_initialize_by(
            var: :cookie_management,
            organization: organization
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

          return false unless @category

          @category["items"] = [] unless @category["items"].is_a?(Array)
          true
        end

        def remove_item
          original_size = @category["items"].size
          @category["items"].reject! { |i| i["name"].to_s == item_name.to_s }
          @category["items"].size < original_size
        end

        def save_cookie_management!
          cookie_management_setting.value = categories_data
          cookie_management_setting.save!
        end
      end
    end
  end
end
