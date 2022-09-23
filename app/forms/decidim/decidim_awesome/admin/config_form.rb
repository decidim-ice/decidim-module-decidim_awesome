# frozen_string_literal: true

require "sassc"

module Decidim
  module DecidimAwesome
    module Admin
      class ConfigForm < Decidim::Form
        include ActionView::Helpers::SanitizeHelper

        attribute :allow_images_in_full_editor, Boolean
        attribute :allow_images_in_small_editor, Boolean
        attribute :allow_images_in_proposals, Boolean
        attribute :use_markdown_editor, Boolean
        attribute :allow_images_in_markdown_editor, Boolean
        attribute :auto_save_forms, Boolean
        attribute :scoped_styles, Hash
        attribute :proposal_custom_fields, Hash
        attribute :scoped_admins, Hash
        attribute :menu, Array[MenuForm]
        attribute :intergram_for_admins, Boolean
        attribute :intergram_for_admins_settings, IntergramForm
        attribute :intergram_for_public, Boolean
        attribute :intergram_for_public_settings, IntergramForm
        attribute :validate_title_min_length, Integer
        attribute :validate_title_max_caps_percent, Integer
        attribute :validate_title_max_marks_together, Integer
        attribute :validate_title_start_with_caps, Boolean
        attribute :validate_body_min_length, Integer
        attribute :validate_body_max_caps_percent, Integer
        attribute :validate_body_max_marks_together, Integer
        attribute :validate_body_start_with_caps, Boolean

        # collect all keys anything not specified in the params (UpdateConfig command ignores it)
        attr_accessor :valid_keys

        validate :css_syntax, if: ->(form) { form.scoped_styles.present? }
        validate :json_syntax, if: ->(form) { form.proposal_custom_fields.present? }
        validates :validate_title_start_with_caps, presence: true
        validates :validate_title_min_length, presence: true, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 100 }
        validates :validate_title_max_caps_percent, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
        validates :validate_title_max_marks_together, presence: true, numericality: { greater_than_or_equal_to: 1 }
        validates :validate_body_start_with_caps, presence: true
        validates :validate_body_min_length, presence: true, numericality: { greater_than_or_equal_to: 0 }
        validates :validate_body_max_caps_percent, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
        validates :validate_body_max_marks_together, presence: true, numericality: { greater_than_or_equal_to: 1 }

        # TODO: validate non general admins are here

        def self.from_params(params, additional_params = {})
          instance = super(params, additional_params)
          instance.valid_keys = params.keys.map(&:to_sym) || []
          instance.sanitize_labels!
          instance
        end

        def css_syntax
          scoped_styles.each do |key, code|
            next unless code

            SassC::Engine.new(code).render
          rescue SassC::SyntaxError => e
            errors.add(:scoped_styles, I18n.t("config.form.errors.incorrect_css", key: key, scope: "decidim.decidim_awesome.admin"))
            errors.add(key.to_sym, e.message)
          end
        end

        def json_syntax
          proposal_custom_fields.each do |key, code|
            next unless code

            JSON.parse(code)
          rescue JSON::ParserError => e
            errors.add(:scoped_styles, I18n.t("config.form.errors.incorrect_json", key: key, scope: "decidim.decidim_awesome.admin"))
            errors.add(key.to_sym, e.message)
          end
        end

        # formBuilder has a bug and do not sanitize text if users copy/paste text with format in the label input
        def sanitize_labels!
          return unless proposal_custom_fields

          proposal_custom_fields.transform_values! do |code|
            next unless code

            json = JSON.parse(code)
            json.map! do |item|
              item["label"] = strip_tags(item["label"])
              item
            end
            JSON.generate(json)
          rescue JSON::ParserError
            code
          end
        end
      end
    end
  end
end
