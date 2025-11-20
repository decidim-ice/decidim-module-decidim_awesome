# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module OpenDataExporterOverride
      extend ActiveSupport::Concern

      included do
        private

        alias_method :decidim_components, :components
        alias_method :decidim_participatory_spaces, :participatory_spaces

        def components
          @awesome_components ||= decidim_components.where.not(id: service.component_with_invisible_resources)
                                                    .where.not(participatory_space: service.spaces_with_invisible_components)
        end

        def participatory_spaces
          @awesome_participatory_spaces ||= decidim_participatory_spaces.select do |space|
            service.spaces_with_invisible_components.all? do |invisible_space|
              invisible_space.exclude?(space)
            end
          end
        end

        def service
          @service ||= Decidim::DecidimAwesome::UserGrantedAuthorizationsService.new(organization, nil)
        end

        # Overrides the parent method to handle missing translations for custom field headers.
        # Custom fields (e.g., "body/full-name/en") don't have translation keys in locale files.
        def get_help_definition(manifest_type, exporter, export_manifest, collection_count)
          help_definition[manifest_type] ||= {}
          manifest_help = help_definition[manifest_type][export_manifest.name] ||= {}
          manifest_help[:headers] ||= {}
          manifest_help[:collection_count] ||= 0

          exporter.headers_without_locales.each do |header|
            translation_key = "decidim.open_data.help.#{export_manifest.name}.#{header}"
            manifest_help[:headers][header] = I18n.exists?(translation_key) ? I18n.t(translation_key) : header
          end

          manifest_help[:collection_count] += collection_count
        end
      end
    end
  end
end
