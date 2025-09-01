# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class UpdateCustomRedirect < Command
        include NeedsConstraintHelpers
        # Public: Initializes the command.
        #
        def initialize(form, item)
          @form = form
          @item = item
          @config_var = :custom_redirects
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
          return broadcast(:invalid, I18n.t("custom_redirects.origin_missing", scope: "decidim.decidim_awesome.admin")) unless url_exists?

          find_var.value&.except!(item.origin)
          find_var.value[form.to_params[0]] = form.to_params[1]
          find_var.save!

          broadcast(:ok, find_var)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :form, :item

        def url_exists?
          return false unless find_var
          return false unless find_var.value.is_a? Hash

          find_var.value[item.origin].present?
        end
      end
    end
  end
end
