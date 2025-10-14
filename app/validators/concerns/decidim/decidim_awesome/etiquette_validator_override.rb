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

          # original method does not take into account accents or anything else than A-Z
          # return original_validate_caps_first(record, attribute, value) if awesome_config.nil?
          percent = if awesome_config.nil?
                      50
                    else
                      awesome_config.to_f
                    end
          return if value.scan(/[[:upper:]]/).length < value.length * percent / 100

          record.errors.add(attribute, options[:message] || I18n.t("too_much_caps", scope: "decidim.decidim_awesome.validators", percent: percent.round))
        end

        def validate_marks(record, attribute, value)
          awesome_config = awesome_config(record, "validate_#{attribute_without_locale(attribute)}_max_marks_together")

          marks = if awesome_config.nil?
                    2
                  else
                    awesome_config.to_i + 1
                  end
          return if value.scan(/[!?¡¿]{#{marks},}/).empty?

          record.errors.add(attribute, options[:message] || :too_many_marks)
        end

        def validate_caps_first(record, attribute, value)
          awesome_config = awesome_config(record, "validate_#{attribute_without_locale(attribute)}_start_with_caps")

          # original method does not take into account accents or anything else than A-Z
          # return original_validate_caps_first(record, attribute, value) if awesome_config.nil?
          return unless awesome_config || awesome_config.nil?
          return if value.scan(/\A[[:lower:]]{1}/).empty?

          record.errors.add(attribute, options[:message] || :must_start_with_caps)
        end

        def record_awesome_config(record)
          record.try(:awesome_config)
        end

        def awesome_config(record, var)
          record_awesome_config(record)&.config&.[](var.to_sym)
        end

        def attribute_without_locale(attribute)
          return attribute unless Decidim.available_locales.map { |locale| "_#{locale}" }.any? { |str| attribute.ends_with?(str) }

          attribute.to_s[0...-3]
        end
      end
    end
  end
end
