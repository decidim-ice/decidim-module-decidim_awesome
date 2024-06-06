# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # This controller handles image uploads for the Tiptap editor
    class EditorImagesController < DecidimAwesome::ApplicationController
      include FormFactory
      include NeedsAwesomeConfig

      # overwrite original rescue_from to ensure we print messages from ajax methods (update)
      rescue_from Decidim::ActionForbidden, with: :ajax_user_has_no_permission

      def create
        enforce_permission_to(:create, :editor_image, awesome_config:)

        @form = form(EditorImageForm).from_params(form_values)
        CreateEditorImage.call(@form) do
          on(:ok) do |image|
            url = image.attached_uploader(:file).path
            url = "#{request.base_url}#{url}" unless url&.start_with?("http")
            render json: { url:, message: I18n.t("decidim_awesome.editor_images.create.success", scope: "decidim") }
          end

          on(:invalid) do |_message|
            render json: { message: I18n.t("decidim_awesome.editor_images.create.error", scope: "decidim") }, status: :unprocessable_entity
          end
        end
      end

      private

      # Rescue ajax calls and print the update.js view which prints the info on the message ajax form
      # Only if the request is AJAX, otherwise behave as Decidim standards
      def ajax_user_has_no_permission
        render json: { message: I18n.t("actions.unauthorized", scope: "decidim.core") }, status: :unprocessable_entity
      end

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
