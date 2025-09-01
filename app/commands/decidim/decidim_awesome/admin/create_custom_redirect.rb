# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CreateCustomRedirect < Command
        include NeedsConstraintHelpers
        # Public: Initializes the command.
        #
        def initialize(form)
          @form = form
          @ident = form.to_params[0]
          @organization = form.current_organization
          @config_var = :custom_redirects
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?
          return broadcast(:invalid, I18n.t("custom_redirects.origin_exists", scope: "decidim.decidim_awesome.admin")) if url_exists?

          create_hash_config!(form.to_params[1])

          broadcast(:ok)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :form

        def url_exists?
          return false unless find_var
          return false unless find_var.value.is_a? Hash

          find_var.value[form.origin].present?
        end
      end
    end
  end
end
