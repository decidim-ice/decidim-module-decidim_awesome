# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      # Limits a controller to the organizations using the HTML code editor.
      module NeedsHtmlCodeEditor
        extend ActiveSupport::Concern

        included do
          include NeedsAwesomeConfig
          include Decidim::AjaxPermissionHandler

          before_action do
            raise ActionController::RoutingError, "Not Found" unless html_code_editor_in_use?
          end
        end
      end
    end
  end
end
