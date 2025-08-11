# lib/decidim/decidim_awesome/authorization_group_service.rb
module Decidim
  module DecidimAwesome
    class AuthorizationGroupService
      def initialize(organization)
        @organization = organization
        @raw_groups = load_raw_groups
        @constraints = load_constraints(@raw_groups)
        @groups = build_groups(@raw_groups)
      end

      def always_groups
        @groups.reject { |group| @constraints[group[:key]].present? }.select { |group| group_handlers([group]).present? }
      end

      def groups_for_space(space)
        select_groups_matching(space)
      end

      def groups_for_component(component)
        select_groups_matching(component)
      end

      def group_handlers(groups)
        groups.flat_map { |group| Array(group[:handlers]) }.compact.compact_blank
      end

      private

      def load_raw_groups
        config = AwesomeConfig.find_by(var: "authorization_groups", organization: @organization)
        config&.value.is_a?(Hash) ? config.value : {}
      end

      def build_groups(raw)
        raw.map do |key, data|
          handlers_field = data["authorization_handlers"]
          if handlers_field.is_a?(Hash)
            handlers = handlers_field.keys
            options = handlers_field.transform_values { |h| h.is_a?(Hash) ? (h["options"] || {}) : {} }
          else
            handlers = Array(handlers_field)
            options = (data["authorization_handlers_options"] || {})
          end

          handlers = Array(handlers).map { |h| h.is_a?(Array) ? h.first : h }.map(&:to_s).compact_blank

          {
            key:,
            handlers:,
            options:
          }
        end
      end

      def load_constraints(raw_groups)
        group_vars = raw_groups.keys.map { |key| "authorization_group_#{key}" }
        configs = AwesomeConfig.where(var: group_vars, organization: @organization)
        constraint_map = ConfigConstraint
                         .where(decidim_awesome_config_id: configs.pluck(:id))
                         .group_by(&:decidim_awesome_config_id)

        configs.each_with_object({}) do |cfg, result|
          settings = constraint_map[cfg.id].to_a.map(&:settings)
          result[cfg.var.sub("authorization_group_", "")] = settings if settings.any?
        end
      end

      def select_groups_matching(context)
        @groups.select do |group|
          group_constraints = @constraints[group[:key]] || []
          group_constraints.any? { |c| constraint_matches?(context:, constraint: c) }
        end
      end

      def constraint_matches?(context:, constraint:)
        return matches_component_constraint?(context, constraint) if context.is_a?(Decidim::Component)

        if [
          Decidim::Assembly,
          Decidim::ParticipatoryProcess,
          Decidim::ParticipatoryProcessGroup
        ].any? { |klass| context.is_a?(klass) }
          return matches_space_constraint?(context, constraint)
        end

        false
      end

      def matches_component_constraint?(component, constraint)
        return false if constraint["component_manifest"].present? && constraint["component_manifest"].to_s != component.manifest.name.to_s

        space = component.participatory_space
        return space_fields_blank?(constraint) if space.nil?

        matches_space_fields?(constraint, space)
      end

      def matches_space_constraint?(space, constraint)
        return false if constraint["component_manifest"].present?

        matches_space_fields?(constraint, space)
      end

      def matches_space_fields?(constraint, space)
        id_match = constraint["participatory_space_id"].blank? || constraint["participatory_space_id"].to_s == space.id.to_s
        space_slug = resolve_space_slug(space)
        slug_match = constraint["participatory_space_slug"].blank? || constraint["participatory_space_slug"].to_s == space_slug.to_s
        manifest_name = space_manifest_name(space)
        manifest_match = constraint["participatory_space_manifest"].blank? || constraint["participatory_space_manifest"].to_s == manifest_name.to_s

        id_match && slug_match && manifest_match
      end

      def space_fields_blank?(constraint)
        constraint["participatory_space_id"].blank? &&
          constraint["participatory_space_slug"].blank? &&
          constraint["participatory_space_manifest"].blank?
      end

      def space_manifest_name(space)
        if space.class.respond_to?(:participatory_space_manifest)
          space.class.participatory_space_manifest.name
        elsif defined?(Decidim::ParticipatoryProcessGroup) && space.is_a?(Decidim::ParticipatoryProcessGroup)
          "process_groups"
        end
      end

      def resolve_space_slug(space)
        return space.slug if space.respond_to?(:slug) && space.slug.present?
        return space.to_param if space.respond_to?(:to_param)

        nil
      end
    end
  end
end
