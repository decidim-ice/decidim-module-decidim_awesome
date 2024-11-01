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
          message = render_to_string(partial: "callout", locals: { i18n_key: "user_authorized", klass: "success" })
          Decidim::Verifications::AuthorizeUser.call(handler, current_organization) do
            on(:transferred) do |transfer|
              message += render_to_string(partial: "callout", locals: { i18n_key: "authorization_transferred", klass: "success" }) if transfer.records.any?
            end
            on(:invalid) do
              message = render_to_string(partial: "callout", locals: { i18n_key: "user_not_authorized", klass: "alert" })
              message += render_to_string("edit")
            end
          end

          render json: {
            message:,
            verified: authorization&.reload.present?,
            userId: user.id,
            handler: params[:handler]
          }
        end

        def destroy
          message = if authorization&.destroy
                      render_to_string(partial: "callout", locals: { i18n_key: "authorization_destroyed", klass: "success" })
                    else
                      render_to_string(partial: "callout", locals: { i18n_key: "authorization_not_destroyed", klass: "alert" })
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
