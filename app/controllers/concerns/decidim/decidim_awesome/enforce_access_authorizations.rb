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

        unless service.granted?
          flash[:alert] = I18n.t("decidim.decidim_awesome.session.authorization_is_required",
                                 authorizations: service.adapters.map(&:fullname).join(", "))
          redirect_to decidim_decidim_awesome.required_authorizations_path(redirect_url: request.fullpath)
        end
      end

      def service
        @service ||= Decidim::DecidimAwesome::AccessAuthorizationService.new(current_user, required_authorization_groups)
      end

      def required_authorization_groups
        return unless awesome_force_authorizations.is_a?(Array)

        @required_authorization_groups ||= awesome_force_authorizations.pluck("authorization_handlers").compact_blank
      end

      def skip_enforcement_for_current_request?
        return true unless user_signed_in? && current_user.confirmed? && !current_user.blocked?
        # Only apply it if the context requires it
        return true if awesome_force_authorizations.blank?

        allowed_controllers.include?(controller_name.to_s)
      end

      def allowed_controllers
        %w(required_authorizations authorizations upload_validations timeouts editor_images locales pages tos) + awesome_config[:force_authorization_allowed_controller_names].to_a
      end
    end
  end
end
