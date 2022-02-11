# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      # Editing menu items
      class CustomRedirectsController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig
        helper ConfigConstraintsHelpers

        layout "decidim/admin/decidim_awesome"

        before_action do
          enforce_permission_to :edit_config, :menu
        end

        def index; end
      end
    end
  end
end
