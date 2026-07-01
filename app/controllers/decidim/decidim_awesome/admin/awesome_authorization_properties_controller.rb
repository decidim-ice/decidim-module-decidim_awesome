# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class AwesomeAuthorizationPropertiesController < DecidimAwesome::Admin::ApplicationController
        helper ConfigConstraintsHelpers

        before_action do
          enforce_permission_to :edit_config, :awesome_authorization_handler
        end

        def edit; end

        private
      end
    end
  end
end
