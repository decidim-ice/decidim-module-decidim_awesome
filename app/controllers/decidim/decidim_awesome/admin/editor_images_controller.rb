# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      # This controller handles image uploads for the hacked Quill editor
      class EditorImagesController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig

        def create
          @form = form(EditorImageForm).from_params(form_values)

          CreateEditorImage.call(@form) do
            on(:ok) do |image|
              render json: { url: image.url, message: I18n.t("decidim_awesome.admin.editor_images.create.success", scope: "decidim") }
            end

            on(:invalid) do |_message|
              render json: { message: I18n.t("decidim_awesome.admin.editor_images.create.error", scope: "decidim") }, status: :unprocessable_entity
            end
          end
        end

        private

        def form_values
          {
            image: params[:image],
            author_id: current_user.id,
            path: request.original_fullpath
          }
        end
      end
    end
  end
end
