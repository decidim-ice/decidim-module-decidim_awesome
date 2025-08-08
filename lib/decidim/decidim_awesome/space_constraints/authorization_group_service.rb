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
          {
            key:,
            handlers: Array(data["authorization_handlers"])
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
        # If a component manifest is specified, it must match the component; otherwise, allow space-level matching
        if constraint["component_manifest"].present? && constraint["component_manifest"].to_s != component.manifest.name.to_s
          return false
        end

        space = component.participatory_space
        # If a component has no participatory space, match only when space-related fields are blank
        return space_fields_blank?(constraint) if space.nil?

        matches_space_fields?(constraint, space)
      end

      def matches_space_constraint?(space, constraint)
        # If a component is specified in the constraint, it should not be enforced at the space level.
        return false if constraint["component_manifest"].present?

        # Let matches_space_fields? decide based on id/slug/manifest (including blank manifest which means any)
        matches_space_fields?(constraint, space)
      end

      def matches_space_fields?(constraint, space)
        id_match = constraint["participatory_space_id"].blank? || constraint["participatory_space_id"].to_s == space.id.to_s
        # Some spaces (like ParticipatoryProcessGroup) may not have slug; fallback to to_param for matching ids passed as slug.
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

      # Returns a consistent manifest name for a given space instance without raising errors.
      # - For real participatory spaces (e.g., Assembly, ParticipatoryProcess) use their manifest name.
      # - For ParticipatoryProcessGroup use a synthetic manifest name "process_groups" to allow grouping rules.
      # - Otherwise return nil.
      def space_manifest_name(space)
        if space.class.respond_to?(:participatory_space_manifest)
          space.class.participatory_space_manifest.name
        elsif defined?(Decidim::ParticipatoryProcessGroup) && space.is_a?(Decidim::ParticipatoryProcessGroup)
          "process_groups"
        else
          nil
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
