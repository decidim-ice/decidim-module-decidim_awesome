# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # Overrides get_help_definition to handle missing translations for dynamic custom field headers.
    # Custom fields like "body/full-name/en" don't have translations, so we add default: "" to I18n.t
    module OpenDataExporterOverride
      extend ActiveSupport::Concern

      included do
        private

        alias_method :decidim_components, :components
        alias_method :decidim_participatory_spaces, :participatory_spaces
        # to remove once https://github.com/decidim/decidim/pull/15459 is merged and backported
        alias_method :decidim_data_for_participatory_space, :data_for_participatory_space

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

        # to remove once https://github.com/decidim/decidim/pull/15459 is merged and backported
        def data_for_participatory_space(export_manifest)
          collection = participatory_spaces.filter { |space| space.manifest.name == export_manifest.manifest.name }.flat_map do |participatory_space|
            export_manifest.collection.call.where(id: participatory_space)
          end
          serializer = export_manifest.open_data_serializer.nil? ? export_manifest.serializer : export_manifest.open_data_serializer
          exporter = Decidim::Exporters::CSV.new(collection, serializer)
          get_help_definition(:spaces, exporter, export_manifest) unless collection.empty?

          exporter.export
        end

        def service
          @service ||= Decidim::DecidimAwesome::UserGrantedAuthorizationsService.new(organization, nil)
        end

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
