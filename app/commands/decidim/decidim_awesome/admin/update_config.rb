# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class UpdateConfig < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A config form
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
          return broadcast(:invalid) if form.invalid?

          begin
            form.attributes.each do |key, val|
              # ignore nil attributes (must specifically be set to false if necessary)
              next if val.nil?

              setting = AwesomeConfig.find_or_initialize_by(var: key, organization: form.current_organization)

              setting.value = val.respond_to?(:attributes) ? val.attributes : val
              setting.save!
            end

            broadcast(:ok)
          rescue ActiveRecord::RecordInvalid => e
            broadcast(:invalid, e.message)
          end
        end

        attr_reader :form
      end
    end
  end
end
