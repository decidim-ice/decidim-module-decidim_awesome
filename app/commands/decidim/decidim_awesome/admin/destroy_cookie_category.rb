# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class DestroyCookieCategory < Decidim::Command
        include NeedsAwesomeConfig
        include HasCookieCategories

        # Public: Initializes the command.
        #
        # category_slug - The slug of the category to destroy.
        # organization - The organization where the category belongs.
        def initialize(category_slug, organization)
          @category_slug = category_slug
          @organization = organization
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the category is not found.
        #
        # Returns nothing.
        def call
          unless remove_category
            broadcast(:invalid)
            return
          end

          save_categories!

          broadcast(:ok)
        rescue ActiveRecord::RecordInvalid => e
          broadcast(:invalid, e.record.errors.full_messages.join(", "))
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :category_slug, :organization

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

        def current_categories
          categories_data["categories"]
        end

        def remove_category
          original_size = current_categories.size
          current_categories.reject! { |c| c["slug"].to_s == category_slug.to_s }
          current_categories.size < original_size
        end

        def save_categories!
          cookie_management_setting.value = categories_data
          cookie_management_setting.save!
        end
      end
    end
  end
end
