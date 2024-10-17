# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # This controller handles image uploads for the Tiptap editor
    class RequiredAuthorizationsController < DecidimAwesome::ApplicationController
      layout "layouts/decidim/authorizations"
      helper_method :granted_authorizations, :pending_authorizations, :redirect_url

      before_action do
        redirect_to redirect_url unless user_signed_in?
        redirect_to redirect_url if user_is_authorized?
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

      def index
        enforce_permission_to :read, :required_authorizations, user_is_authorized: user_is_authorized?
      end

      private

      def pending_authorizations
        @pending_authorizations ||= required_authorizations.filter { |manifest| current_authorizations.pluck(:name).exclude?(manifest.name) }
      end

      def granted_authorizations
        @granted_authorizations ||= required_authorizations.filter { |manifest| current_authorizations.pluck(:name).include?(manifest.name) }
      end
    end
  end
end
