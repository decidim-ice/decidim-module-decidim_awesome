# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class Authorizator
      def initialize(user, admin_authorizations)
        @user = user
        @admin_authorizations = admin_authorizations
        @admin_authorizations = [] if @admin_authorizations.blank? || !admin_authorizations.is_a?(Array)
        @organization = user.organization
      end
      attr_reader :user, :organization, :admin_authorizations

      def authorizations
        return @authorizations if defined?(@authorizations)

        @authorizations = organization.available_authorizations.filter_map do |name|
          workflow = Decidim::Verifications.find_workflow_manifest(name)
          next unless workflow

          authorization = Decidim::Authorization.find_by(user: user, name: name)
          {
            name: name,
            fullname: workflow.fullname,
            granted: authorization&.granted?,
            pending: authorization.present? && !authorization.granted?,
            managed: admin_authorizations.include?(name.to_s)
          }
        end
        @authorizations = @authorizations.sort_by { |i| i[:managed] ? 0 : 1 }
      end
    end
  end
end
