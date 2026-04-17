# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class UpdateUsersAutoblockConfig < Command
        def initialize(form)
          @form = form
          @users_autoblocks_config = AwesomeConfig.find_or_initialize_by(var: :users_autoblocks_config, organization: form.current_organization)
        end

        def call
          return broadcast(:invalid) if form.invalid?

          users_autoblocks_config.value = form.to_params
          users_autoblocks_config.save!
          broadcast(:ok, users_autoblocks_config)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :form, :users_autoblocks_config
      end
    end
  end
end
