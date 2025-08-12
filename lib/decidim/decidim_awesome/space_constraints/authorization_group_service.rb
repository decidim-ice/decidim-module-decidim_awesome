# frozen_string_literal: true

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

      # Public: returns all defined groups for this organization (both constrained and unconstrained).
      def all_groups
        @groups
      end

      private

      def load_raw_groups
        config = AwesomeConfig.find_by(var: "authorization_groups", organization: @organization)
        config&.value.is_a?(Hash) ? config.value : {}
      end

      def build_groups(raw)
        raw.map do |key, data|
          handlers, options = parse_handlers_and_options(data)
          handlers = normalize_handlers(handlers)

          { key:, handlers:, options: }
        end
      end

      def parse_handlers_and_options(data)
        handlers_field = data["authorization_handlers"]
        if handlers_field.is_a?(Hash)
          handlers = handlers_field.keys
          options = extract_options_from_hash_field(handlers_field)
        else
          handlers = Array(handlers_field)
          options = data["authorization_handlers_options"] || {}
        end
        [handlers, options]
      end

      def extract_options_from_hash_field(handlers_field)
        handlers_field.transform_values do |h|
          h.is_a?(Hash) ? (h["options"] || {}) : {}
        end
      end

      def normalize_handlers(handlers)
        Array(handlers).map { |h| h.is_a?(Array) ? h.first : h }.map(&:to_s).compact_blank
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
        matcher = Decidim::DecidimAwesome::AuthorizationConstraintMatcher.new
        @groups.select do |group|
          group_constraints = @constraints[group[:key]] || []
          group_constraints.any? { |c| matcher.matches?(context: context, constraint: c) }
        end
      end
    end
  end
end
