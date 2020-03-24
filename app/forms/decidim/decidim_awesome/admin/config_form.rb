# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      # A form object used to configure the endpoint.
      #
      class ConfigForm < Decidim::Form
        attribute :allow_images_in_full_editor, Boolean
      end
    end
  end
end
