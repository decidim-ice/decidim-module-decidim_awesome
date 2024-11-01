# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class AdminAuthorizationsController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig

        layout false
        helper_method :user, :authorization, :workflow, :handler

        before_action do
          # TODO: ensure authorization is allowed to be managed by the current admin
          # TODO ensure allow_admins_authorization is enabled
        end

        def edit
          render "authorization" if authorization
        end

        def update
          # TODO: authorization.update!(handler_params)
          message = if rand(2) == 1
                      render_to_string(partial: "callout", locals: { i18n_key: "user_authorized", klass: "success" })
                    else
                      render_to_string(partial: "callout", locals: { i18n_key: "user_not_authorized", klass: "alert" })
                    end
          render json: {
            message:,
            verified: authorization&.reload.present?,
            userId: user.id,
            handler: params[:handler]
          }
        end

        def destroy
          # TODO: authorization.destroy!
          message = if rand(2) == 1
                      render_to_string(partial: "callout", locals: { i18n_key: "authorization_not_destroyed", klass: "alert" })
                    else
                      render_to_string(partial: "callout", locals: { i18n_key: "authorization_destroyed", klass: "success" })
                    end
          render json: {
            message:,
            verified: authorization&.reload.present?,
            userId: user.id,
            handler: params[:handler]
          }
        end

        private

        def user
          @user ||= Decidim::User.find(params[:id])
        end

        def authorization
          @authorization ||= Decidim::Authorization.where.not(granted_at: nil).find_by(user:, name: params[:handler])
        end

        def workflow
          @workflow ||= Decidim::Verifications.find_workflow_manifest(params[:handler])
        end

        def handler
          @handler ||= Decidim::AuthorizationHandler.handler_for(params[:handler], handler_params)
        end

        def handler_params
          (params[:authorization_handler] || {}).merge(user:)
        end
      end
    end
  end
end
