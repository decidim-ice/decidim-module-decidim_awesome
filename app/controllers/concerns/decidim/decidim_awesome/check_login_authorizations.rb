# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module CheckLoginAuthorizations
      extend ActiveSupport::Concern

      included do
        include ::Decidim::DecidimAwesome::NeedsAwesomeConfig
        before_action :check_required_login_authorizations
      end

      private

      def check_required_login_authorizations
        return unless user_signed_in?
        return if allowed_controllers.include?(controller_name)

        unless user_is_authorized?
          flash[:alert] = I18n.t("decidim.decidim_awesome.session.authorization_is_required",
                                 authorizations: required_authorizations.map(&:fullname).join(", "))
          redirect_to decidim_decidim_awesome.required_authorizations_path(redirect_url: request.fullpath)
        end
      end

      def user_is_authorized?
        return true if required_authorizations.blank?

        @user_is_authorized ||= if awesome_config[:force_authorization_with_any_method]
                                  current_authorizations.any?
                                else
                                  current_authorizations.count == required_authorizations.count
                                end
      end

      def required_authorizations
        return unless awesome_config[:force_authorization_after_login].is_a?(Array)

        @required_authorizations ||= Decidim::Verifications::Adapter.from_collection(
          awesome_config[:force_authorization_after_login] & current_organization.available_authorization_handlers
        )
      end

      def current_authorizations
        @current_authorizations ||= Decidim::Verifications::Authorizations.new(
          organization: current_organization,
          user: current_user,
          name: required_authorizations.map(&:name),
          granted: true
        )
      end

      def allowed_controllers
        %w(required_authorizations authorizations account)
      end
    end
  end
end
