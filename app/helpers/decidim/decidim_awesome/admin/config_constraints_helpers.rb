# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      module ConfigConstraintsHelpers
        include Decidim::TranslatableAttributes

        def participatory_spaces_list(manifest)
          return {} if manifest.blank?

          space = Decidim.find_participatory_space_manifest(manifest)
          return {} unless space

          klass = space.model_class_name.constantize
          klass.where(organization: current_organization).map do |item|
            [item.slug, translated_attribute(item.title)]
          end.to_h
        end

        def participatory_space_manifests
          Decidim.participatory_space_manifests.pluck(:name).map do |name|
            [name.to_sym, I18n.t("decidim.admin.menu.#{name}")]
          end.to_h
        end

        def component_manifests
          Decidim.component_manifests.pluck(:name).map do |name|
            [name.to_sym, I18n.t("decidim.components.#{name}.name")]
          end.to_h
        end

        def translate_constraint_value(constraint, key)
          value = constraint.settings[key]
          case key.to_sym
          when :participatory_space_manifest
            participatory_space_manifests[value.to_sym] || value
          when :participatory_space_slug
            manifest = constraint.settings["participatory_space_manifest"]
            participatory_spaces_list(manifest)[value] || value
          when :component_manifest
            component_manifests[value.to_sym] || value
          else
            value
          end
        end
      end
    end
  end
end
