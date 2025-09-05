# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module EtiquetteValidatorOverride
      extend ActiveSupport::Concern

      included do
        alias_method :original_validate_caps, :validate_caps
        alias_method :original_validate_marks, :validate_marks
        alias_method :original_validate_caps_first, :validate_caps_first

        private

        def validate_caps(record, attribute, value)
          awesome_config = awesome_config(record, "validate_#{attribute_without_locale(attribute)}_max_caps_percent")
          return original_validate_caps(record, attribute, value) if awesome_config.nil?

          percent = awesome_config.to_f
          return if value.scan(/[[:upper:]]/).length < value.length * percent / 100

          record.errors.add(attribute, options[:message] || I18n.t("too_much_caps", scope: "decidim.decidim_awesome.validators", percent: percent.round))
        end

        def validate_marks(record, attribute, value)
          awesome_config = awesome_config(record, "validate_#{attribute_without_locale(attribute)}_max_marks_together")
          return original_validate_marks(record, attribute, value) if awesome_config.nil?

          marks = awesome_config.to_i + 1
          return if value.scan(/[!?¡¿]{#{marks},}/).empty?

          record.errors.add(attribute, options[:message] || :too_many_marks)
        end

        def validate_caps_first(record, attribute, value)
          awesome_config = awesome_config(record, "validate_#{attribute_without_locale(attribute)}_start_with_caps")
          return original_validate_caps_first(record, attribute, value) if awesome_config.nil?
          return unless awesome_config
          return if value.scan(/\A[[:lower:]]{1}/).empty?

          record.errors.add(attribute, options[:message] || :must_start_with_caps)
        end

        def awesome_config(record, var)
          config = record.try(:awesome_config)&.config
          return unless config.is_a?(Hash)

          config[var.to_sym]
        end

        def attribute_without_locale(attribute)
          return attribute unless Decidim.available_locales.map { |locale| "_#{locale}" }.any? { |str| attribute.ends_with?(str) }

          attribute.to_s[0...-3]
        end
      end
    end
  end
end
