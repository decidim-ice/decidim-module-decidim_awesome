# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class UpdateConfig < Command
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
          if form.invalid?
            message = form.errors[:scoped_styles].join("; ") if @form.errors[:scoped_styles].any?
            message = form.errors[:scoped_admins].join("; ") if @form.errors[:scoped_admins].any?
            return broadcast(:invalid, message, form.errors)
          end

          begin
            form.attributes.each do |key, val|
              # ignore nil attributes (must specifically be set to false if necessary)
              next unless form.valid_keys.include?(key.to_sym)

              setting = AwesomeConfig.find_or_initialize_by(var: key, organization: form.current_organization)

              value = if [:authorization_groups, :admin_authorization_groups].include?(key.to_sym)
                        form.public_send("#{key}_attributes")
                      else
                        val.respond_to?(:attributes) ? val.attributes : val
                      end

              setting.value = value
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
