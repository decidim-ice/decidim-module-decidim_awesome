# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # Files uploaded by admins from the HTML code editor, stored along with the editor images.
    class EditorFile < EditorImage
      attached_options :file, uploader: Decidim::DecidimAwesome::EditorFileUploader
    end
  end
end
