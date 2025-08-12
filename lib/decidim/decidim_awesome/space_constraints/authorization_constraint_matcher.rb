# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # Small PORO extracted to reduce complexity in AuthorizationGroupService.
    # It knows how to evaluate a constraint hash against a given context
    # (Component or Participatory Space).
    class AuthorizationConstraintMatcher
      def matches?(context:, constraint:)
        return matches_component?(context, constraint) if context.is_a?(Decidim::Component)
        return matches_space?(context, constraint) if space_like?(context)

        false
      end

      private

      def space_like?(obj)
        [
          Decidim::Assembly,
          Decidim::ParticipatoryProcess,
          Decidim::ParticipatoryProcessGroup
        ].any? { |klass| obj.is_a?(klass) }
      end

      def matches_component?(component, constraint)
        return false if present_and_different?(constraint["component_manifest"], component.manifest.name)

        space = component.participatory_space
        return space_fields_blank?(constraint) if space.nil?

        matches_space_fields?(constraint, space)
      end

      def matches_space?(space, constraint)
        # If constraint targets a component manifest, ignore for pure space
        return false if constraint["component_manifest"].present?

        matches_space_fields?(constraint, space)
      end

      def matches_space_fields?(constraint, space)
        id_match = constraint["participatory_space_id"].blank? || constraint["participatory_space_id"].to_s == space.id.to_s
        slug = resolve_space_slug(space)
        slug_match = constraint["participatory_space_slug"].blank? || constraint["participatory_space_slug"].to_s == slug.to_s
        manifest_name = space_manifest_name(space)

        manifest_value = constraint["participatory_space_manifest"].to_s
        manifest_match = if manifest_value.blank?
                           true
                         elsif manifest_value == "system"
                           manifest_name.to_s != "participatory_processes"
                         else
                           manifest_value == manifest_name.to_s
                         end

        id_match && slug_match && manifest_match
      end

      def space_fields_blank?(constraint)
        constraint["participatory_space_id"].blank? &&
          constraint["participatory_space_slug"].blank? &&
          constraint["participatory_space_manifest"].blank?
      end

      def present_and_different?(expected, actual)
        expected.present? && expected.to_s != actual.to_s
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
