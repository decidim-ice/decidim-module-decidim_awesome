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
          config = AwesomeConfig.find_by(organization: organization, var: :cookie_management)
          @store = CookieManagementStore.new(organization, config&.value)
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

          @store.save!(@store.stored_categories)

          broadcast(:ok)
        rescue ActiveRecord::RecordInvalid => e
          broadcast(:invalid, e.record.errors.full_messages.join(", "))
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :category_slug, :item_name, :organization

        def find_category
          @category = @store.stored_categories.find { |c| c["slug"].to_s == category_slug.to_s }
          return false unless @category

          @category["items"] = [] unless @category["items"].is_a?(Array)
          true
        end

        def remove_item
          original_size = @category["items"].size
          default_item = reset_cookie_item_to_default(category_slug, item_name)

          if default_item
            index = @category["items"].find_index { |i| i["name"].to_s == item_name.to_s }
            return false unless index

            @category["items"][index] = default_item
          else
            @category["items"].reject! { |i| i["name"].to_s == item_name.to_s }
            return @category["items"].size < original_size
          end

          true
        end
      end
    end
  end
end
