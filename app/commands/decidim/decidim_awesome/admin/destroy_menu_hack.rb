# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class DestroyMenuHack < Command
        include NeedsConstraintHelpers
        # Public: Initializes the command.
        #
        # item - the menu item to destroy
        # organization
        def initialize(item, menu_name, organization)
          @item = item
          @organization = organization
          @config_var = menu_name
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless url_exists?

          find_var.value&.reject! { |i| i["url"] == item.url }
          find_var.save!

          broadcast(:ok, @item)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :organization, :item

        def url_exists?
          return false unless find_var
          return false unless find_var.value.is_a? Array

          find_var.value&.detect { |i| i["url"] == item.url }
        end
      end
    end
  end
end
