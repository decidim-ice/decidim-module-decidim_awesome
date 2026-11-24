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

        private

        # These requests have their own address, so the editor is checked for the whole organization
        def html_code_editor_in_use?
          return false unless organization_awesome_config[:html_code_editor]

          awesome_config_instance.setting_for(:html_code_editor).constraints.none? { |constraint| constraint.settings["participatory_space_manifest"] == "none" }
        end
      end
    end
  end
end
