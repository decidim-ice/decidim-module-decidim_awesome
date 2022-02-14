# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CreateCustomRedirect < Rectify::Command
        # Public: Initializes the command.
        #
        def initialize(form)
          @form = form
          @redirections = AwesomeConfig.find_or_initialize_by(var: :custom_redirects, organization: form.current_organization)
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

          create_redirection!
          broadcast(:ok)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :form, :redirections

        delegate :to_params, to: :form

        def create_redirection!
          redirections.value = {} unless redirections.value.is_a? Hash
          redirections.value[to_params[0]] = to_params[1]
          redirections.save!
        end

        def url_exists?
          return false unless redirections
          return false unless redirections.value.is_a? Hash

          redirections.value[form.origin].present?
        end
      end
    end
  end
end
