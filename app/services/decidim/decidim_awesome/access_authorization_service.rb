# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class AccessAuthorizationService
      def initialize(user, organization, authorization_groups = [])
        @user = user
        @organization = organization
        @available_handlers = organization.available_authorizations & Decidim.authorization_workflows.map(&:name)
        @authorization_groups = authorization_groups.filter_map do |group|
          group.filter_map do |handler, options|
            next unless @available_handlers.include?(handler)

            [handler, options]
          end.to_h
        end.compact_blank
      end

      attr_reader :user, :organization, :authorization_groups

      def granted?
        return false unless user
        return true if authorization_groups.blank?

        # if one group is authorized that's ok
        # inside a group, all adapters must be authorized
        authorization_groups.detect do |group|
          statuses = authorization_statuses_for(group)
          next if statuses.blank?

          statuses.all? { |status| status == :ok }
        end
      end

      def authorization_handlers
        @authorization_handlers ||= authorization_groups.flat_map do |group|
          next unless group.is_a?(Hash)

          group.keys
        end.uniq
      end

      def adapters
        @authorizations ||= adapters_for(authorization_handlers)
      end

      def authorization_status(method)
        authorization_statuses_for({ method => authorization_groups.flat_map { |group| group[method] } }).first
      end

      private

      def adapters_for(handlers)
        Decidim::Verifications::Adapter.from_collection(
          handlers & organization.available_authorizations & Decidim.authorization_workflows.map(&:name)
        )
      end

      def authorization_statuses_for(group)
        @authorization_statuses_for ||= {}

        adapters_for(group.keys).map do |adapter|
          next @authorization_statuses_for[adapter.name] if @authorization_statuses_for.has_key?(adapter.name)

          @authorization_statuses_for[adapter.name] = begin
            authorization = Decidim::Verifications::Authorizations.new(
              organization:,
              user:,
              name: adapter.name,
              granted: true
            ).first

            adapter.authorize(authorization, group[adapter.name]["options"], nil, nil)&.first
          end
        end
      end
    end
  end
end
