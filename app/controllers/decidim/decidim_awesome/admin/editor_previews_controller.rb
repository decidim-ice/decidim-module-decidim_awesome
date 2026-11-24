# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      # Renders the content of the HTML code editor as it is displayed to the visitors.
      class EditorPreviewsController < Decidim::Admin::ApplicationController
        include NeedsHtmlCodeEditor

        layout false

        def create
          enforce_permission_to :create, :editor_image

          @content = params[:content].to_s
        end
      end
    end
  end
end
