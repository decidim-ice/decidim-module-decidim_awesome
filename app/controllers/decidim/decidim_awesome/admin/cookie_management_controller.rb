# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CookieManagementController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig

        before_action do
          enforce_permission_to :edit_config, :cookie_management
        end

        def index; end
      end
    end
  end
end
