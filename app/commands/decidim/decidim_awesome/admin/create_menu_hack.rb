# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CreateMenuHack < Rectify::Command
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
          return broadcast(:invalid, I18n.t("menu_hacks.url_exists", scope: "decidim.decidim_awesome.admin")) if url_exists?

          menu.value = [] unless menu.value.is_a? Array
          menu.value << form.to_params
          menu.save!
          broadcast(:ok, menu)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :form, :menu

        def url_exists?
          return false unless menu

          menu.value&.detect { |item| item["url"] == form.url }
        end
      end
    end
  end
end
