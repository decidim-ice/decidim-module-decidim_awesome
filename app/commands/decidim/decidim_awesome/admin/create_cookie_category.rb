# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CreateCookieCategory < Decidim::Command
        include NeedsAwesomeConfig

        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
          config = AwesomeConfig.find_by(organization: form.current_organization, var: :cookie_management)
          @store = CookieManagementStore.new(form.current_organization, config&.value)
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form is invalid or slug already exists.
        #
        # Returns nothing.
        def call
          generate_slug_if_needed
          return broadcast(:invalid) if form.invalid?
          return broadcast(:invalid) if duplicate_slug?

          add_category
          @store.save!(@store.stored_categories)

          broadcast(:ok)
        rescue ActiveRecord::RecordInvalid => e
          broadcast(:invalid, e.record.errors.full_messages.join(", "))
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :form

        def generate_slug_if_needed
          form.slug = form.generate_slug_from_title if form.slug.blank?
        end

        def duplicate_slug?
          if @store.stored_categories.any? { |c| c["slug"].to_s == form.slug }
            form.errors.add(:slug, :taken)
            return true
          end
          false
        end

        def add_category
          @store.stored_categories << form.to_params
        end
      end
    end
  end
end
