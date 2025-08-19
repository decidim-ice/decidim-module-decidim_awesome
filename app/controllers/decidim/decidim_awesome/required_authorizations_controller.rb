# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # Lists the authorizations required for the current user/context and helps
    # them complete those. Delegates the business logic to AccessAuthorizationService.
    class RequiredAuthorizationsController < DecidimAwesome::ApplicationController
      include ActionView::Helpers::SanitizeHelper
      layout "layouts/decidim/authorizations"
      helper_method :granted_authorizations, :pending_authorizations, :missing_authorizations, :redirect_url, :authorization_help_text

      before_action do
        # If the user is already authorized for the required handlers, send them
        # back to the original destination (or root). This avoids loops because
        # redirect_url defaults to decidim.root_path when it points back here.
        # redirect_to redirect_url if user_signed_in? && service.granted? && request.path != redirect_url
        console
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

      delegate :authorization_handlers, :adapters, to: :service

      def current_authorizations
        @current_authorizations ||= Decidim::Verifications::Authorizations.new(
          organization: current_organization,
          user: current_user,
          name: authorization_handlers,
          granted: true
        )
      end

      def missing_authorizations
        @missing_authorizations ||= adapters.filter do |manifest|
          Decidim::Verifications::Authorizations.new(
            organization: current_organization,
            user: current_user,
            name: authorization_handlers
          ).pluck(:name).exclude?(manifest.name)
        end
      end

      def pending_authorizations
        @pending_authorizations ||= adapters.filter do |manifest|
          Decidim::Verifications::Authorizations.new(
            organization: current_organization,
            user: current_user,
            name: authorization_handlers,
            granted: false
          ).pluck(:name).include?(manifest.name)
        end
      end

      def granted_authorizations
        @granted_authorizations ||= adapters.filter { |manifest| current_authorizations.pluck(:name).include?(manifest.name) }
      end

      def service
        @service ||= Decidim::DecidimAwesome::AccessAuthorizationService.new(current_user, context_authorizations)
      end

      # we need to detect the context from the redirect_url passed
      def context_force_authorizations
        @context_force_authorizations ||= begin
          config = Config.new(current_organization)
          config.context_from_request(redirect_url)
          config.collect_sub_configs_values("force_authorization")
        end
      end

      def context_authorizations
        @context_authorizations ||= (context_force_authorizations.pluck("authorization_handlers").compact_blank if context_force_authorizations.is_a?(Array))
      end

      # show the first help text available
      def authorization_help_text
        return unless context_force_authorizations.is_a?(Array)

        context_force_authorizations.pluck("force_authorization_help_text").find do |text|
          text = translated_attribute(text)
          strip_tags(text).strip.present? ? text : nil
        end
      end
    end
  end
end
