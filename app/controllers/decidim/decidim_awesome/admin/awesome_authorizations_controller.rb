# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class AwesomeAuthorizationsController < DecidimAwesome::Admin::ApplicationController
        helper ConfigConstraintsHelpers
        helper_method :available?, :authorization_groups

        before_action do
          enforce_permission_to :edit_config, :awesome_authorization_handler
        end

        def index
        end
        
        private
        
        def available?
          @available ||= current_organization.available_authorizations.include?("awesome_authorization_handler")
        end
        
        def authorization_groups
          @authorization_groups ||= current_organization.awesome_authorization_groups
        end
      end
    end
  end
end
