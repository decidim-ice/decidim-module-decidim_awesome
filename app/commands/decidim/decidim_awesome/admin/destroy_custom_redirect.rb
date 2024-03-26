# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class DestroyCustomRedirect < Command
        # Public: Initializes the command.
        #
        # item - the redirections item to destroy
        # organization
        def initialize(item, organization)
          @item = item
          @organization = organization
          @redirections = AwesomeConfig.find_by(var: :custom_redirects, organization:)
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless url_exists?

          redirections.value&.except!(item.origin)
          redirections.save!

          broadcast(:ok, @item)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :organization, :item, :redirections

        def url_exists?
          return false unless redirections
          return false unless redirections.value.is_a? Hash

          redirections.value[item.origin].present?
        end
      end
    end
  end
end
