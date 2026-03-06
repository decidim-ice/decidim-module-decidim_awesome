# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # This controller handles image uploads for the Tiptap editor
    class EditorImagesController < DecidimAwesome::ApplicationController
      include Decidim::FormFactory
      include Decidim::AjaxPermissionHandler

      def create
        enforce_permission_to(:create, :editor_image, awesome_config:)

        @form = form(EditorImageForm).from_params(form_values)
        CreateEditorImage.call(@form) do
          on(:ok) do |image|
            url = image.attached_uploader(:file).path
            render json: { url:, message: I18n.t("success", scope: "decidim.editor_images.create") }
          end

          on(:invalid) do |_message|
            render json: { message: I18n.t("error", scope: "decidim.editor_images.create") }, status: :unprocessable_entity
          end
        end
      end

      private

      def form_values
        {
          file: params[:image],
          author_id: current_user.id,
          path: request.referer
        }
      end
    end
  end
end
