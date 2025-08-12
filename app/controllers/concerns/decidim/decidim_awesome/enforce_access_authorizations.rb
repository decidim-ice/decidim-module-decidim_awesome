# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module EnforceAccessAuthorizations
      extend ActiveSupport::Concern

      included do
        include ::Decidim::DecidimAwesome::NeedsAwesomeConfig

        before_action :check_access_authorizations
        before_action :check_required_login_authorizations
      end

      private

      def check_required_login_authorizations
        enforce_authorizations(:required)
      end

      def check_access_authorizations
        enforce_authorizations(:access)
      end

      def check_content_authorizations
        check_access_authorizations
      end

      def login_authorization_service
        @login_authorization_service ||= Decidim::DecidimAwesome::LoginAuthorizationService.new(self)
      end

      def enforce_authorizations(kind)
        service = login_authorization_service

        case kind
        when :required
          return unless service.login_authorization_required?
          return if service.user_is_authorized?

          authorizations = service.localized_required_authorizations_fullnames
          redirect_path = decidim_decidim_awesome.required_authorizations_path(redirect_url: request.fullpath)

        when :access
          return if service.skip_access_authorization_check?

          handlers = service.access_authorization_handlers
          return if handlers.blank? || service.user_has_handlers?(handlers)

          authorizations = handlers_fullnames(handlers)
          redirect_path = service.redirect_path_with_handlers(handlers)

        else
          return
        end

        flash_authorization_alert(authorizations)
        redirect_to redirect_path
      end

      def flash_authorization_alert(authorizations)
        flash[:alert] = I18n.t(
          "decidim.decidim_awesome.session.authorization_is_required",
          authorizations:
        )
      end

      def handlers_fullnames(handlers)
        Decidim::Verifications::Adapter.from_collection(handlers).map(&:fullname).join(", ")
      end
    end
  end
end
