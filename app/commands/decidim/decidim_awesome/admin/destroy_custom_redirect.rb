# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class DestroyCustomRedirect < Command
        include NeedsConstraintHelpers
        # Public: Initializes the command.
        #
        # item - the redirects item to destroy
        # organization
        def initialize(item, organization)
          @item = item
          @organization = organization
          @config_var = :custom_redirects
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless url_exists?

          find_var.value&.except!(item.origin)
          find_var.save!

          broadcast(:ok, item)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :item

        def url_exists?
          return false unless find_var
          return false unless find_var.value.is_a? Hash

          find_var.value[item.origin].present?
        end
      end
    end
  end
end
