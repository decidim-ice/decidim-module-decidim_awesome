# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class UserGrantedAuthorizationsService
      def initialize(organization, user)
        @organization = organization
        @user = user
        @available_handlers = organization.available_authorizations & Decidim.authorization_workflows.map(&:name)
      end

      attr_reader :user, :organization, :available_handlers

      def user_authorizations
        @user_authorizations ||= Decidim::Authorization.where(user:, name: available_handlers).where.not(granted_at: nil).pluck(:name)
      end

      # Returns a hash with only the authorization handlers enabled in the organization defined in the
      # force_authorizations config var and granted for the user
      # { "key" => { "handler_name" => { "options" => {...}} } }
      def granted_handlers
        @granted_handlers ||= all_handlers.filter_map do |key, group|
          # all handlers in the group must be granted
          next if (group.keys - user_authorizations).any?

          [key, group]
        end.to_h
      end

      def non_granted_handlers
        @non_granted_handlers ||= all_handlers.filter_map do |key, group|
          # at least one handler in the group must not be granted
          next if (group.keys - user_authorizations).empty?

          [key, group]
        end.to_h
      end

      # Returns a hash with all the authorization handlers enabled in the organization defined in the
      # force_authorizations config var and their status for the user
      # { "key" => { "handler_name" => { "options" => {...}} } }
      def all_handlers
        @all_handlers ||= AwesomeConfig.find_by(organization:, var: "force_authorizations")&.value&.filter_map do |key, group|
          handlers = group&.fetch("authorization_handlers", {})&.filter do |handler, _options|
            available_handlers.include?(handler)
          end
          next if handlers.blank?

          [key, handlers]
        end.to_h
      end

      # Returns a list of components ids which resources are invisible because authorization is not granted in that context
      def component_with_invisible_resources
        constraints_with_invisible_resources.filter_map do |constraint|
          component_manifest = constraint.settings["component_manifest"]
          component_id = constraint.settings["component_id"]

          where = {}
          where[:manifest_name] = component_manifest if component_manifest.present?
          where[:id] = component_id if component_id.present?

          space_manifest = constraint.settings["participatory_space_manifest"]
          space_slug = constraint.settings["participatory_space_slug"]

          space_query = space_query_for(space_manifest, space_slug)
          where[:participatory_space] = space_query if space_query

          organization.published_components.where(where)
        end
      end

      # Returns a list of components that are invisible because authorization is not granted in that context
      def spaces_with_invisible_components
        constraints_with_invisible_components.filter_map do |constraint|
          space_manifest = constraint.settings["participatory_space_manifest"]
          space_slug = constraint.settings["participatory_space_slug"]

          space_query_for(space_manifest, space_slug)
        end
      end

      private

      def space_query_for(space_manifest, space_slug = nil)
        manifest = Decidim.participatory_space_manifests.find { |m| m.name.to_s == space_manifest }
        return unless manifest

        model_class = manifest.model_class_name.safe_constantize
        return unless model_class

        where = { organization: organization }
        if space_slug.present?
          id_key = model_class.column_names.include?("slug") ? :slug : :id
          where[id_key] = space_slug
        end

        manifest.participatory_spaces.call(organization).public_spaces.where(where)
      end

      def constraints_with_invisible_components
        @constraints_with_invisible_components ||= ConfigConstraint.where(awesome_config: awesome_sub_configs)
                                                                   .where("settings ? 'participatory_space_manifest'")
                                                                   .where.not("settings ? 'component_manifest' OR settings ? 'component_id'")
      end

      def constraints_with_invisible_resources
        @constraints_with_invisible_resources ||= ConfigConstraint.where(awesome_config: awesome_sub_configs)
                                                                  .where("settings ? 'component_manifest' OR settings ? 'component_id'")
      end

      def awesome_sub_configs
        @awesome_sub_configs ||= AwesomeConfig.where(organization:, var: sub_configs)
                                              .where.not(id: ConfigConstraint.select(:decidim_awesome_config_id)
                                                                             .where("settings->>'participatory_space_manifest' = 'none'"))
      end

      def available_spaces
        @available_spaces ||= organization.public_participatory_spaces
      end

      def available_components
        @available_components ||= organization.published_components
      end

      def sub_configs
        @sub_configs ||= non_granted_handlers.keys.map { |key| "force_authorization_#{key}" }
      end

      def service
        @service ||= AccessAuthorizationService.new(user, organization)
      end
    end
  end
end
