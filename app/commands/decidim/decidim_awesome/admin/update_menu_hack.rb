# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class UpdateMenuHack < Command
        include NeedsConstraintHelpers
        # Public: Initializes the command.
        #
        def initialize(form, menu_name)
          @form = form
          @config_var = menu_name
          @organization = form.current_organization
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          find_var.value = [] unless find_var.value.is_a? Array
          find_var.value = find_var.value.filter { |i| i.is_a? Hash }
          found = false
          find_var.value.map! do |item|
            if item["url"] == form.url
              found = true
              form.to_params
            else
              item
            end
          end
          find_var.value << form.to_params unless found
          find_var.save!
          broadcast(:ok, find_var)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :form
      end
    end
  end
end
