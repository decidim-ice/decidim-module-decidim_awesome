# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # Lists the authorizations required for the current user/context and helps
    # them complete those. Delegates the business logic to LoginAuthorizationService.
    class RequiredAuthorizationsController < DecidimAwesome::ApplicationController
      layout "layouts/decidim/authorizations"
      helper_method :granted_authorizations, :pending_authorizations, :missing_authorizations, :redirect_url

      before_action do
        # If the user is already authorized for the required handlers, send them
        # back to the original destination (or root). This avoids loops because
        # redirect_url defaults to decidim.root_path when it points back here.
        redirect_to redirect_url if user_signed_in? && login_authorization_service.user_is_authorized? && request.path != redirect_url
      end

      def redirect_url
        @redirect_url ||= begin
          path = params[:redirect_url] || request.referer
          if path.blank? || path.include?(decidim_decidim_awesome.required_authorizations_path.split("?").first)
            decidim.root_path
          else
            path
          end
        end
      end

      private

      def required_authorizations
        login_authorization_service.required_authorizations
      end

      def current_authorizations
        @current_authorizations ||= Decidim::Verifications::Authorizations.new(
          organization: current_organization,
          user: current_user,
          name: required_authorizations.map(&:name),
          granted: true
        )
      end

      def missing_authorizations
        @missing_authorizations ||= required_authorizations.filter do |manifest|
          Decidim::Verifications::Authorizations.new(
            organization: current_organization,
            user: current_user,
            name: required_authorizations.map(&:name)
          ).pluck(:name).exclude?(manifest.name)
        end
      end

      def pending_authorizations
        @pending_authorizations ||= required_authorizations.filter do |manifest|
          Decidim::Verifications::Authorizations.new(
            organization: current_organization,
            user: current_user,
            name: required_authorizations.map(&:name),
            granted: false
          ).pluck(:name).include?(manifest.name)
        end
      end

      def granted_authorizations
        @granted_authorizations ||= required_authorizations.filter { |manifest| current_authorizations.pluck(:name).include?(manifest.name) }
      end

      def login_authorization_service
        @login_authorization_service ||= Decidim::DecidimAwesome::LoginAuthorizationService.new(self)
      end
    end
  end
end
