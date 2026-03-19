# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class DestroyCookieItem < Decidim::Command
        # Public: Initializes the command.
        #
        # category_slug - The slug of the category where the item belongs.
        # item_name - The name of the item to destroy.
        # organization - The organization where the item belongs.
        # config - The AwesomeConfig instance for cookie management.
        def initialize(category_slug, item_name, organization)
          @category_slug = category_slug.to_s
          @item_name = item_name.to_s
          @organization = organization
          @config = AwesomeConfig.find_by(organization: organization, var: :cookie_management)
        end

        attr_reader :category_slug, :item_name, :organization, :config

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the category is not found or the item is not found.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless config&.value

          category = config.value[category_slug]
          return broadcast(:invalid) unless category
          return broadcast(:invalid) unless category["items"]&.has_key?(item_name)

          category["items"].delete(item_name)
          config.save!

          broadcast(:ok)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end
      end
    end
  end
end
