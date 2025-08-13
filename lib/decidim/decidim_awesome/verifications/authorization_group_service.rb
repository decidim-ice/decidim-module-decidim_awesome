# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class AuthorizationGroupService
      def initialize(controller)
        @controller = controller
        @organization = controller.send(:current_organization)
      end

      def parse_handlers(value)
        normalize_handlers(value)
      end

      def groups_config
        @groups_config ||= (config.unfiltered_config[:authorization_groups] || {}).deep_stringify_keys
      end

      def groups_subs
        @groups_subs ||= config.sub_configs_for("authorization_group").transform_keys(&:to_s)
      end

      def keys
        @keys ||= groups_config.keys.sort
      end

      def classify_keys
        return @classified if defined?(@classified)

        classified_groups = { global: [], contextual: [], disabled: [] }

        keys.each do |group_key|
          raw_constraints = raw_constraints_for(group_key)
          has_constraints = raw_constraints.any?
          disabled_by_none = raw_constraints.any? do |constraint|
            constraint.settings["participatory_space_manifest"] == "none"
          end

          if !has_constraints
            classified_groups[:global] << group_key
          elsif disabled_by_none
            classified_groups[:disabled] << group_key
          else
            classified_groups[:contextual] << group_key
          end
        end

        @classified = classified_groups
      end

      def global_keys
        classify_keys[:global]
      end

      def contextual_keys
        classify_keys[:contextual]
      end

      def disabled_keys
        classify_keys[:disabled]
      end

      def applicable_contextual_keys
        config.context_from_request(@controller.request)
        contextual_keys.select { |key| constraints_match?(raw_constraints_for(key)) }
      end

      def handlers_for(keys_or_item)
        Array(keys_or_item).flat_map { |k| handlers_for_key(k) }.map(&:to_s).uniq
      end

      def adapters_for_names(names)
        Decidim::Verifications::Adapter.from_collection(registered_names(names))
      end

      def any_method?(key)
        !!groups_config.dig(key.to_s, "force_authorization_with_any_method")
      end

      def handlers_for_key(key)
        parse_handlers(groups_config.dig(key.to_s, "authorization_handlers"))
      end

      def raw_constraints_for(key)
        ac = groups_subs[key.to_s]
        Array(ac&.all_constraints)
      end

      def registered_names(list)
        Array(list).select { |name| registered?(name) }
      end

      private

      def config
        @config ||= Decidim::DecidimAwesome::Config.new(@organization)
      end

      def build_item(key)
        raw = raw_constraints_for(key)
        {
          key:,
          has_constraints: raw.any?,
          disabled_by_none: raw.any? { |c| c.settings["participatory_space_manifest"] == "none" }
        }
      end

      def constraints_match?(raw)
        return false if raw.blank?
        return true if config.valid_in_context?(raw)

        manifest = config.context[:participatory_space_manifest].to_s
        has_system = raw.any? { |c| c.settings["participatory_space_manifest"].to_s == "system" }
        has_system && manifest != "participatory_processes"
      end

      def normalize_handlers(value)
        case value
        when Hash
          value.keys.map(&:to_s)
        when Array
          value.flatten.map(&:to_s)
        when String, Symbol
          [value.to_s]
        else
          []
        end
      end

      def registered?(name)
        Decidim::Verifications::Adapter.from_collection([name.to_s]).present?
      rescue StandardError
        false
      end
    end
  end
end
