# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      module ConfigConstraintsHelpers
        OTHER_MANIFESTS = [:none, :system, :process_groups].freeze

        include Decidim::TranslatableAttributes

        def check(status)
          content_tag(:span, icon(status ? "check" : "x", class: "icon", aria_label: status, role: "img"), class: "text-#{status ? "success" : "alert"}")
        end

        # returns only non :disabled vars in config
        def enabled_configs(vars)
          vars.filter do |var|
            config_enabled? var
          end
        end

        def config_enabled?(var)
          unless var.is_a?(Array)
            return false unless DecidimAwesome.config.has_key?(var.to_sym)

            return DecidimAwesome.config.send(var) != :disabled
          end

          var.detect { |v| DecidimAwesome.config.send(v) != :disabled }
        end

        def participatory_space_manifests
          manifests = OTHER_MANIFESTS.index_with { |m| I18n.t("decidim.decidim_awesome.admin.config.#{m}") }
          Decidim.participatory_space_manifests.pluck(:name).each do |name|
            manifests[name.to_sym] = I18n.t("decidim.admin.menu.#{name}")
          end
          manifests
        end

        def component_manifests(space = nil)
          return {} if OTHER_MANIFESTS.include?(space)

          Decidim.component_manifests.pluck(:name).map do |name|
            [name.to_sym, I18n.t("decidim.components.#{name}.name")]
          end.to_h
        end

        def participatory_spaces_list(manifest)
          space = model_for_manifest(manifest)
          return {} if space.blank?

          space.where(organization: current_organization).map do |item|
            [item.try(:slug) || item.id.to_s, translated_attribute(item.title)]
          end.to_h
        end

        def components_list(manifest, slug)
          space = model_for_manifest(manifest)
          return {} unless space&.column_names&.include? "slug"

          components = Component.where(participatory_space: space.find_by(slug: slug))
          components.map do |item|
            [item.id, "#{item.id}: #{translated_attribute(item.name)}"]
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
          when :component_id
            component = Component.find_by(id: value)
            return "#{component.id}: #{translated_attribute(component.name)}" if component

            value
          else
            value
          end
        end

        def md5(text)
          Digest::MD5.hexdigest(text)
        end

        private

        def model_for_manifest(manifest)
          return nil if manifest.blank?

          return Decidim::ParticipatoryProcessGroup if manifest == "process_groups"

          space = Decidim.find_participatory_space_manifest(manifest)
          return nil unless space

          space.model_class_name.constantize
        end
      end
    end
  end
end
