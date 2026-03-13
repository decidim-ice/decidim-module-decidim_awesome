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
          unless remove_category
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

        attr_reader :category_slug, :organization

        def remove_category
          original_size = @store.stored_categories.size
          default_cat = reset_category_to_default(category_slug)

          if default_cat
            index = @store.stored_categories.find_index { |c| c["slug"].to_s == category_slug.to_s }
            return false unless index

            @store.stored_categories[index] = default_cat
          else
            @store.stored_categories.reject! { |c| c["slug"].to_s == category_slug.to_s }
            return @store.stored_categories.size < original_size
          end

          true
        end
      end
    end
  end
end
