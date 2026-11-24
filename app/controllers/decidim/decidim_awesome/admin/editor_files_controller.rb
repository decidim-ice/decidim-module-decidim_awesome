# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      # Stores the files uploaded from the HTML code editor.
      class EditorFilesController < Decidim::Admin::ApplicationController
        include NeedsHtmlCodeEditor

        def create
          enforce_permission_to :create, :editor_image

          @form = form(EditorFileForm).from_params(form_values)

          CreateEditorFile.call(@form) do
            on(:ok) do |editor_file|
              render json: {
                url: editor_file.attached_uploader(:file).path,
                filename: editor_file.file.filename.to_s,
                content_type: editor_file.file.content_type
              }
            end

            on(:invalid) do
              render json: { message: @form.errors[:file].to_sentence }, status: :unprocessable_content
            end
          end
        end

        private

        def form_values
          {
            file: params[:file],
            author_id: current_user.id,
            path: request.referer
          }
        end
      end
    end
  end
end
