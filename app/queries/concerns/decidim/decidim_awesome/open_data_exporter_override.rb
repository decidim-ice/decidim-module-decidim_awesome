# frozen_string_literal: true

module Decidim
  module DecidimAwesome
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
      end
    end
  end
end
