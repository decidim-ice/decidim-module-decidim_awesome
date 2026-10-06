# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CreateMenuHack < Command
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
          return broadcast(:invalid, I18n.t("menu_hacks.url_exists", scope: "decidim.decidim_awesome.admin")) if url_exists?

          create_array_config!(form.to_params)

          broadcast(:ok, find_var)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :form

        def url_exists?
          return false unless find_var

          find_var.value&.detect { |i| i["url"] == form.normalized_url.gsub(/\?.*/, "") }
        end
      end
    end
  end
end
