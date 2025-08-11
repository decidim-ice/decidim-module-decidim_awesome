# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module CheckLoginAuthorizations
      extend ActiveSupport::Concern

      included do
        include ::Decidim::DecidimAwesome::NeedsAwesomeConfig

        before_action :check_required_login_authorizations
        before_action :check_contextual_login_authorizations
      end

      private

      def check_required_login_authorizations
        service = login_authorization_service
        return unless service.login_authorization_required?
        return if service.user_is_authorized?

        flash[:alert] = I18n.t(
          "decidim.decidim_awesome.session.authorization_is_required",
          authorizations: service.localized_required_authorizations_fullnames
        )
        redirect_to decidim_decidim_awesome.required_authorizations_path(redirect_url: request.fullpath)
      end

      def check_contextual_login_authorizations
        service = login_authorization_service
        return if service.skip_contextual_check?

        handlers = service.contextual_handlers
        return if handlers.blank? || service.user_has_handlers?(handlers)

        flash[:alert] = I18n.t(
          "decidim.decidim_awesome.session.authorization_is_required",
          authorizations: Decidim::Verifications::Adapter.from_collection(handlers).map(&:fullname).join(", ")
        )
        redirect_to service.redirect_path_with_handlers(handlers)
      end

      def login_authorization_service
        @login_authorization_service ||= Decidim::DecidimAwesome::LoginAuthorizationService.new(self)
      end
    end
  end
end
