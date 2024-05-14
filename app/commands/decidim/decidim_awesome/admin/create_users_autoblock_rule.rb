# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CreateUsersAutoblockRule < Command
        # Public: Initializes the command.
        #
        def initialize(form)
          @form = form
          @users_autoblocks = AwesomeConfig.find_or_initialize_by(var: :users_autoblocks, organization: form.current_organization)
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          users_autoblocks.value = [] unless users_autoblocks.value.is_a? Array
          users_autoblocks.value << to_params
          users_autoblocks.save!
          broadcast(:ok, users_autoblocks)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :form, :users_autoblocks

        def to_params
          params = form.to_params
          params[:id] = (users_autoblocks.value.map { |item| item["id"] }.max || 0) + 1

          params
        end
      end
    end
  end
end
