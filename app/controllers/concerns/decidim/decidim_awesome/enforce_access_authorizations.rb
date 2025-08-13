# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module EnforceAccessAuthorizations
      extend ActiveSupport::Concern

      included do
        include ::Decidim::DecidimAwesome::NeedsAwesomeConfig
        before_action :enforce_authorizations
      end

      private

      def enforce_authorizations
        return if skip_enforcement_for_current_request?

        service = access_authorization_service
        return if enforce_global_authorizations(service)
        return unless service.controller_requires_authorization?

        enforce_context_authorizations(service)
      end

      def enforce_global_authorizations(service)
        return false if service.authorization_groups_global.blank?

        adapters = service.required_authorizations
        return false if adapters.blank?

        return true if service.user_is_authorized?

        flash_authorization_alert(fullnames(adapters))
        redirect_to_required(redirect_url: request.fullpath)
        true
      end

      def enforce_context_authorizations(service)
        adapters = service.required_authorizations_for_current_controller
        return if adapters.blank?
        return if user_authorized_for_current_context?(adapters)

        flash_authorization_alert(fullnames(adapters))
        redirect_to_required(redirect_url: request.fullpath, handlers: adapters.map(&:name))
      end

      def user_authorized_for_current_context?(adapters)
        names = Array(adapters).map(&:name)
        return true if names.blank?
        return false unless user_signed_in?

        Decidim::Authorization
          .where(user: current_user, name: names)
          .where.not(granted_at: nil)
          .exists?
      end

      def access_authorization_service
        @access_authorization_service ||= Decidim::DecidimAwesome::AccessAuthorizationService.new(self)
      end

      def fullnames(adapters)
        Array(adapters).map(&:fullname).join(", ")
      end

      def redirect_to_required(redirect_url:, handlers: nil)
        params = { redirect_url: }
        params[:handlers] = handlers if handlers.present?
        redirect_to decidim_decidim_awesome.required_authorizations_path(params)
      end

      def flash_authorization_alert(authorizations)
        flash[:alert] = I18n.t(
          "decidim.decidim_awesome.session.authorization_is_required",
          authorizations:
        )
      end

      def skip_enforcement_for_current_request?
        return true unless user_signed_in? && current_user.confirmed? && !current_user.blocked?

        allowed_controllers.include?(controller_name.to_s)
      end

      def allowed_controllers
        %w(required_authorizations authorizations upload_validations timeouts editor_images locales pages tos) + awesome_config[:force_authorization_allowed_controller_names].to_a
      end
    end
  end
end
