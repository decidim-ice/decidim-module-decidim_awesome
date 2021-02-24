# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class DestroyMenuHack < Rectify::Command
        # Public: Initializes the command.
        #
        # item - the menu item to destroy
        # organization
        def initialize(item, menu_name, organization)
          @item = item
          @organization = organization
          @menu = AwesomeConfig.find_by(var: menu_name, organization: organization)
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless url_exists?

          menu.value&.reject! { |i| i["url"] == item.url }
          menu.save!

          broadcast(:ok, @item)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :organization, :item, :menu

        def url_exists?
          return false unless menu
          return false unless menu.value.is_a? Array

          menu.value&.detect { |i| i["url"] == item.url }
        end
      end
    end
  end
end
