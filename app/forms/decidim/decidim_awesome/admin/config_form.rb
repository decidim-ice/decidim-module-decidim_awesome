# frozen_string_literal: true

require "sassc"

module Decidim
  module DecidimAwesome
    module Admin
      class ConfigForm < Decidim::Form
        include ActionView::Helpers::SanitizeHelper
        include TranslatableAttributes

        attribute :allow_images_in_editors, Boolean
        attribute :allow_videos_in_editors, Boolean
        attribute :allow_images_in_proposals, Boolean
        attribute :auto_save_forms, Boolean
        attribute :scoped_styles, Hash
        attribute :scoped_admin_styles, Hash
        attribute :proposal_custom_fields, Hash
        attribute :proposal_private_custom_fields, Hash
        attribute :user_timezone, Boolean
        attribute :force_authorization_after_login, Array
        attribute :force_authorization_with_any_method, Boolean
        attribute :hashcash_signup, Boolean
        attribute :hashcash_signup_bits, Integer, default: Decidim::DecidimAwesome.hashcash_signup_bits
        attribute :hashcash_login, Boolean
        attribute :hashcash_login_bits, Integer, default: Decidim::DecidimAwesome.hashcash_login_bits
        translatable_attribute :force_authorization_help_text, String
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

        # collect all keys specified in the params (UpdateConfig command ignores everything else)
        attr_accessor :valid_keys

        validate :css_syntax
        validate :json_syntax

        validates :validate_title_min_length, presence: true, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 100 }
        validates :validate_title_max_caps_percent, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
        validates :validate_title_max_marks_together, presence: true, numericality: { greater_than_or_equal_to: 1 }
        validates :validate_body_min_length, presence: true, numericality: { greater_than_or_equal_to: 0 }
        validates :validate_body_max_caps_percent, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
        validates :validate_body_max_marks_together, presence: true, numericality: { greater_than_or_equal_to: 1 }
        validates :hashcash_signup_bits, presence: true, numericality: { greater_than_or_equal_to: 10, less_than_or_equal_to: 50 }
        validates :hashcash_login_bits, presence: true, numericality: { greater_than_or_equal_to: 10, less_than_or_equal_to: 50 }
        validate :force_authorization_after_login_is_valid
        # TODO: validate non general admins are here

        def self.from_params(params, additional_params = {})
          instance = super
          instance.force_authorization_after_login = instance.force_authorization_after_login.compact_blank if instance.force_authorization_after_login.present?
          instance.valid_keys = extract_valid_keys_from_params(params)
          instance.sanitize_labels!
          instance.sanitize_arrays!
          instance
        end

        def self.extract_valid_keys_from_params(params)
          keys = []
          params.each do |key, _value|
            keys << if key.to_s.starts_with?("force_authorization_help_text_")
                      :force_authorization_help_text if keys.exclude?(:force_authorization_help_text)
                    else
                      key.to_sym
                    end
          end
          keys
        end

        def additional_proposal_sorting_labels
          Decidim::DecidimAwesome.possible_additional_proposal_sortings.index_by do |sorting|
            I18n.t(sorting, scope: "decidim.proposals.proposals.orders")
          end
        end

        def css_syntax
          styles = {}
          styles.merge!(scoped_styles: scoped_styles.values) if scoped_styles.present?
          styles.merge!(scoped_admin_styles: scoped_admin_styles.values) if scoped_admin_styles.present?
          styles.each do |key, values|
            next if values.blank?

            values.each { |code| SassC::Engine.new(code).render }
          rescue SassC::SyntaxError => e
            errors.add(key, I18n.t("config.form.errors.incorrect_css", key:, scope: "decidim.decidim_awesome.admin"))
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
            errors.add(key, I18n.t("config.form.errors.incorrect_json", key:, scope: "decidim.decidim_awesome.admin"))
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

        def sanitize_arrays!
          scoped_admins.transform_values! do |code|
            code.is_a?(Array) ? code.compact_blank : code
          end
        end

        private

        def force_authorization_after_login_is_valid
          return if force_authorization_after_login.blank?

          invalid = force_authorization_after_login - (current_organization.available_authorizations & Decidim.authorization_workflows.map(&:name))
          return if invalid.empty?

          errors.add(:force_authorization_after_login, :invalid)
        end
      end
    end
  end
end
