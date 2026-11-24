# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CreateEditorFile < Command
        # Public: Initializes the command.
        #
        # form - The form with the file to store.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          broadcast(:ok, create_editor_file!)
        end

        private

        attr_reader :form

        def create_editor_file!
          EditorFile.create!(
            path: form.path,
            decidim_author_id: form.author_id,
            organization: form.organization,
            file: form.file
          )
        end
      end
    end
  end
end
