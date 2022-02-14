# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class UpdateCustomRedirect < Rectify::Command
        # Public: Initializes the command.
        #
        def initialize(form, item)
          @form = form
          @item = item
          @redirects = AwesomeConfig.find_by(var: :custom_redirects, organization: form.current_organization)
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?
          return broadcast(:invalid, I18n.t("custom_redirects.origin_missing", scope: "decidim.decidim_awesome.admin")) unless url_exists?

          redirects.value&.except!(item.origin)
          redirects.value[to_params[0]] = to_params[1]
          redirects.save!

          broadcast(:ok, redirects)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :form, :redirects, :item

        delegate :to_params, to: :form

        def url_exists?
          return unless redirects
          return unless redirects.value.is_a? Hash

          redirects.value[item.origin].present?
        end
      end
    end
  end
end
