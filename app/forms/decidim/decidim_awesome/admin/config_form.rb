# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class ConfigForm < Decidim::Form
        attribute :allow_images_in_full_editor, Boolean
        attribute :allow_images_in_small_editor, Boolean
        attribute :allow_images_in_proposals, Boolean
        attribute :use_markdown_editor, Boolean
        attribute :allow_images_in_markdown_editor, Boolean
        attribute :auto_save_forms, Boolean
        attribute :scoped_styles, Hash
        attribute :scoped_admins, Hash
        attribute :menu, Array[MenuForm]
        attribute :intergram_for_admins, Boolean
        attribute :intergram_for_admins_settings, IntergramForm
        attribute :intergram_for_public, Boolean
        attribute :intergram_for_public_settings, IntergramForm

        # collect all keys anything not specified in the params (UpdateConfig command ignores it)
        attr_accessor :valid_keys

        validate :css_syntax, if: ->(form) { form.scoped_styles.present? }

        # TODO: validate non general admins are here

        def self.from_params(params, additional_params = {})
          instance = super(params, additional_params)
          instance.valid_keys = params.keys.map(&:to_sym) || []
          instance
        end

        def css_syntax
          scoped_styles.each do |key, code|
            SassC::Engine.new(code).render
          rescue SassC::SyntaxError => e
            errors.add(:scoped_styles, I18n.t("config.form.errors.incorrect_css", key: key, scope: "decidim.decidim_awesome.admin"))
            errors.add(key.to_sym, e.message)
          end
        end
      end
    end
  end
end
