# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class CreateEditorImage < ::Rectify::Command
      # Creates a blueprint.
      #
      # form - The form with the data.
      def initialize(form)
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        transaction do
          create_editor_image!
        end

        broadcast(:ok, @editor_image)
      end

      private

      def create_editor_image!
        @editor_image = EditorImage.create!(
          path: form.path,
          decidim_author_id: form.current_user.id,
          organization: form.organization,
          file: form.file
        )
      end

      attr_reader :form
    end
  end
end
