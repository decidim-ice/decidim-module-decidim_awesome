# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class DestroyCookieCategory < Decidim::Command
        include NeedsAwesomeConfig

        # Public: Initializes the command.
        #
        # category_slug - The slug of the category to destroy.
        # organization - The organization where the category belongs.
        def initialize(category_slug, organization)
          @category_slug = category_slug
          @organization = organization
          @config = AwesomeConfig.find_by(organization: organization, var: :cookie_management)
        end

        attr_reader :category_slug, :organization, :config

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the category is not found.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless config&.value

          config.value.delete(category_slug)
          config.save!

          broadcast(:ok)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end
      end
    end
  end
end
