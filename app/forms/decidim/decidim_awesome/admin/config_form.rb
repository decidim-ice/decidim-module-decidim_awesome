# frozen_string_literal: true

require "sassc"

module Decidim
  module DecidimAwesome
    module Admin
      class ConfigForm < Decidim::Form
        include ActionView::Helpers::SanitizeHelper

        attribute :allow_images_in_editors, Boolean
        attribute :allow_videos_in_editors, Boolean
        attribute :allow_images_in_proposals, Boolean
        attribute :auto_save_forms, Boolean
        attribute :scoped_styles, Hash
        attribute :proposal_custom_fields, Hash
        attribute :proposal_private_custom_fields, Hash
        attribute :scoped_admins, Hash
        attribute :menu, [MenuForm]
        attribute :intergram_for_admins, Boolean
        attribute :intergram_for_admins_settings, IntergramForm
        attribute :intergram_for_public, Boolean
        attribute :intergram_for_public_settings, IntergramForm
        attribute :validate_title_min_length, Integer, default: 15
        attribute :validate_title_max_caps_percent, Integer, default: 25
        attribute :validate_title_max_marks_together, Integer, default: 1
        attribute :validate_title_start_with_caps, Boolean, default: true
        attribute :validate_body_min_length, Integer, default: 15
        attribute :validate_body_max_caps_percent, Integer, default: 25
        attribute :validate_body_max_marks_together, Integer, default: 1
        attribute :validate_body_start_with_caps, Boolean, default: true
        attribute :additional_proposal_sortings, Array, default: Decidim::DecidimAwesome.possible_additional_proposal_sortings

        # collect all keys anything not specified in the params (UpdateConfig command ignores it)
        attr_accessor :valid_keys

        validate :css_syntax, if: ->(form) { form.scoped_styles.present? }
        validate :json_syntax

        validates :validate_title_min_length, presence: true, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 100 }
        validates :validate_title_max_caps_percent, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
        validates :validate_title_max_marks_together, presence: true, numericality: { greater_than_or_equal_to: 1 }
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

        def additional_proposal_sorting_labels
          Decidim::DecidimAwesome.possible_additional_proposal_sortings.index_by do |sorting|
            I18n.t(sorting, scope: "decidim.proposals.proposals.orders")
          end
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
          fields = {}
          fields.merge!(proposal_custom_fields: proposal_custom_fields.values) if proposal_custom_fields.present?
          fields.merge!(proposal_private_custom_fields: proposal_private_custom_fields.values) if proposal_private_custom_fields.present?
          fields.each do |key, values|
            next if values.blank?

            values.each { |code| JSON.parse(code) }
          rescue JSON::JSONError => e
            errors.add(key, I18n.t("config.form.errors.incorrect_json", key: key, scope: "decidim.decidim_awesome.admin"))
            errors.add(key.to_sym, e.message)
          end
        end

        # formBuilder has a bug and do not sanitize text if users copy/paste text with format in the label input
        def sanitize_labels!
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

          proposal_private_custom_fields.transform_values! do |code|
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
