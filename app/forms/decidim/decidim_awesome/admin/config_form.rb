# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      # A form object used to configure the endpoint.
      #
      class ConfigForm < Decidim::Form
        attribute :allow_images_in_full_editor, Boolean
        attribute :allow_images_in_small_editor, Boolean
        attribute :allow_images_in_proposals, Boolean
        attribute :use_markdown_editor, Boolean
        attribute :allow_images_in_markdown_editor, Boolean
        attribute :auto_save_forms, Boolean
        attribute :menu_hacks, Boolean
        attribute :intergram_for_admins, Boolean
        attribute :intergram_for_admins_settings, IntergramForm
        attribute :intergram_for_public, Boolean
        attribute :intergram_for_public_settings, IntergramForm
      end
    end
  end
end
