# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Processors
      class ModerationProcessor
        include AwesomeHelpers

        def initialize(object)
          @object = object
        end

        def self.process(object)
          processor = new object
          return unless processor.valid_object?

          config = processor.config
          return unless config

          config.context_from_component!(object.component)

          return unless config.constrained_in_context?(:auto_moderation_rules)

          config_moderation = config.setting_for(:auto_moderation_rules)
          rules = config_moderation.value.select { |_id, rule| rule["enabled"] }
          return if rules.empty?

          rules.each do |rule_id, rule|
            rule_manifest = processor.get_rule_manifest(rule["rule_type"])
            checker_class = rule_manifest.checker_class.constantize
            checker = checker_class.new(rule["rule_options"])
            next unless checker.check(object)

            rule["counter"] += 1

            targets = rule["targets"]
            targets.each do |_id, target|
              action_manifest = processor.get_action_manifest(target["action_type"])
              handler_class = action_manifest.handler_class.constantize
              handler = handler_class.new(object, target["action_options"])
              byebug
              handler.execute

              target["hits"] += 1
            end

            config_moderation.value[rule_id] = rule
            config_moderation.save
          end
        end

        def get_action_manifest(action_type)
          Decidim::DecidimAwesome.moderation_actions_registry.manifests.find { |manifest| manifest.name.to_s == action_type }
        end

        def get_rule_manifest(rule_type)
          Decidim::DecidimAwesome.moderation_rules_registry.manifests.find { |manifest| manifest.name.to_s == rule_type }
        end

        def valid_object?
          case @object
          when Decidim::Proposals::Proposal
            :proposals
          when Decidim::Comments::Comment
            :comments
          end
        end

        def rules_applies_to_object?(rule)
          rule["targets"].any? do |_id, target|
            target["object_type"] == object_type && target["action_type"] == action_type
          end
        end

        def object_type
          case @object
          when Decidim::Proposals::Proposal
            "proposal"
          when Decidim::Comments::Comment
            "comment"
          end
        end

        def config
          organization = @object.organization
          @config ||= Decidim::DecidimAwesome::Config.new(organization)
        end
      end
    end
  end
end
