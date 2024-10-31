# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class AdminAuthorizationsController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig

        layout false
        helper_method :user, :authorization

        before_action do
          # TODO ensure authorization is allowed to be managed by the current admin
          # TODO ensure allow_admins_authorization is enabled
        end

        def edit
          render "authorization" if authorization
        end

        private

        def user
          @user ||= Decidim::User.find(params[:id])
        end

        def authorization
          @authorization ||= Decidim::Authorization.where.not(granted_at: nil).find_by(user:, name: params[:handler])
        end
      end
    end
  end
end