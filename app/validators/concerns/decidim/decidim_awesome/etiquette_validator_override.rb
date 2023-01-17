# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module EtiquetteValidatorOverride
      extend ActiveSupport::Concern

      included do
        private

        def validate_caps(record, attribute, value)
          percent = awesome_config(record, "validate_#{attribute}_max_caps_percent").to_f
          return if value.scan(/[[:upper:]]/).length < value.length * percent / 100

          record.errors.add(attribute, options[:message] || I18n.t("too_much_caps", scope: "decidim.decidim_awesome.validators", percent: percent.round))
        end

        def validate_marks(record, attribute, value)
          marks = awesome_config(record, "validate_#{attribute}_max_marks_together").to_i + 1
          return if value.scan(/[!?¡¿]{#{marks},}/).empty?

          record.errors.add(attribute, options[:message] || :too_many_marks)
        end

        def validate_caps_first(record, attribute, value)
          return unless awesome_config(record, "validate_#{attribute}_start_with_caps")
          return if value.scan(/\A[[:lower:]]{1}/).empty?

          record.errors.add(attribute, options[:message] || :must_start_with_caps)
        end

        def awesome_config(record, var)
          config = record.try(:awesome_config)&.config
          return unless config.is_a?(Hash)

          config[var.to_sym]
        end
      end
    end
  end
end
