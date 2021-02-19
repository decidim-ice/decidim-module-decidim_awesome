# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class UpdateMenuHack < Rectify::Command
        # Public: Initializes the command.
        #
        def initialize(form, menu_name)
          @form = form
          @menu = AwesomeConfig.find_or_initialize_by(var: menu_name, organization: form.current_organization)
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          menu.value = [] unless menu.value.is_a? Array
          menu.value = menu.value.filter { |i| i.is_a? Hash }
          found = false
          menu.value.map! do |item|
            if item["url"] == form.url
              found = true
              form.to_params
            else
              item
            end
          end
          menu.value << form.to_params unless found
          menu.save!
          broadcast(:ok, menu)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :form, :menu
      end
    end
  end
end
