# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class AccessAuthorizationService
      def initialize(user, authorization_groups = [])
        @user = user
        @organization = user.organization
        @authorization_groups = authorization_groups
      end

      attr_reader :user, :organization, :authorization_groups

      def granted?
        return true if authorization_groups.blank?

        # if one group is authorized that's ok
        # inside a group, all adapters must be authorized
        authorization_groups.detect do |group|
          adapters_for(group.keys).all? do |adapter|
            authorization = Decidim::Verifications::Authorizations.new(
              organization:,
              user:,
              name: adapter.name,
              granted: true
            ).first

            adapter.authorize(authorization, group[adapter.name]["options"])&.first == :ok if authorization
          end
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

      private

      def adapters_for(handlers)
        Decidim::Verifications::Adapter.from_collection(
          handlers & organization.available_authorizations & Decidim.authorization_workflows.map(&:name)
        )
      end
    end
  end
end
