# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class AwesomeVerificationsController < DecidimAwesome::Admin::ApplicationController
        helper ConfigConstraintsHelpers
        helper_method :available?

        before_action do
          enforce_permission_to :edit_config, :force_authorizations
        end

        def index
        end

        private

        def available?
          @available ||= current_organization.available_authorizations.include?("awesome_authorization_handler")
        end
          
      end
    end
  end
end
