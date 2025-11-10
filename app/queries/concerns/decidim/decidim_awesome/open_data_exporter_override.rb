# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # Overrides get_help_definition to handle missing translations for dynamic custom field headers.
    # Custom fields like "body/full-name/en" don't have translations, so we add default: "" to I18n.t
    module OpenDataExporterOverride
      extend ActiveSupport::Concern

      included do
        private

        def get_help_definition(manifest_type, exporter, export_manifest, collection_count)
          help_definition[manifest_type] ||= {}
          manifest_help = help_definition[manifest_type][export_manifest.name] ||= {}
          manifest_help[:headers] ||= {}
          manifest_help[:collection_count] ||= 0

          exporter.headers_without_locales.each do |header|
            manifest_help[:headers][header] = I18n.t(
              "decidim.open_data.help.#{export_manifest.name}.#{header}",
              default: ""
            )
          end

          manifest_help[:collection_count] += collection_count
        end
      end
    end
  end
end
