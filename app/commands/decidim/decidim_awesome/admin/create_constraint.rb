# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CreateConstraint < Command
        # Public: Initializes the command.
        #
        # form - A constraint form
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid, form.errors.full_messages.join(". ")) if form.invalid?
          return broadcast(:invalid) if attributes.blank?

          begin
            @constraint = ConfigConstraint.create!(
              awesome_config: form.context.setting,
              settings: attributes
            )
            broadcast(:ok, @constraint)
          rescue ActiveRecord::RecordNotUnique
            broadcast(:invalid, I18n.t("decidim.decidim_awesome.admin.constraints.errors.not_unique"))
          rescue StandardError => e
            broadcast(:invalid, e.message)
          end
        end

        private

        attr_reader :form, :constraint

        def attributes
          form.attributes.filter { |_i, v| v.present? }
        end
      end
    end
  end
end
