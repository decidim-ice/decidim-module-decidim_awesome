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
        attribute :scoped_styles, Hash
        attribute :intergram_for_admins, Boolean
        attribute :intergram_for_admins_settings, IntergramForm
        attribute :intergram_for_public, Boolean
        attribute :intergram_for_public_settings, IntergramForm

        # convert to nil anything not specified in the params (UpdateConfig command ignores nil entries)
        def self.from_params(params, additional_params = {})
          instance = super(params, additional_params)
          nillable_keys = instance.attributes.keys - params.keys.map(&:to_sym)
          nillable_keys.each do |key|
            instance.send("#{key}=", nil)
          end
          instance
        end
      end
    end
  end
end
