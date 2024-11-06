# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class AdminAuthorizationsController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig

        layout false
        helper_method :user, :authorization, :workflow, :handler, :conflict
        # overwrite original rescue_from to ensure we print messages from ajax methods
        rescue_from Decidim::ActionForbidden, with: :json_error

        before_action do
          enforce_permission_to :edit_config, :admins_available_authorizations, handler: workflow.name
        end

        def edit
          render "authorization" if authorization
        end

        def update
          if conflict
            message = render_to_string("conflict")
          else
            message = render_to_string(partial: "callout", locals: { i18n_key: "user_authorized", klass: "success" })
            Decidim::Verifications::AuthorizeUser.call(handler, current_organization) do
              on(:transferred) do |transfer|
                message += render_to_string(partial: "callout", locals: { i18n_key: "authorization_transferred", klass: "success" }) if transfer.records.any?
              end
              on(:invalid) do
                if force_verification.present?
                  create_forced_authorization
                else
                  message = render_to_string(partial: "callout", locals: { i18n_key: "user_not_authorized", klass: "alert" })
                  message += render_to_string("edit", locals: { with_override: true })
                end
              end
              on(:ok) do
                Decidim::ActionLogger.log("admin_creates_authorization", current_user, user, nil, user_id: user.id, handler: workflow.name, handler_name: workflow.fullname)
              end
            end
          end

          render json: {
            message: message,
            granted: granted?,
            userId: user.id,
            handler: workflow.name
          }
        end

        def destroy
          message = if destroy_authorization
                      render_to_string(partial: "callout", locals: { i18n_key: "authorization_destroyed", klass: "success" })
                    else
                      render_to_string(partial: "callout", locals: { i18n_key: "authorization_not_destroyed", klass: "alert" })
                    end

          render json: {
            message: message,
            granted: granted?,
            userId: user.id,
            handler: workflow.name
          }
        end

        private

        def create_forced_authorization
          Decidim::Authorization.create_or_update_from(handler)
          Decidim::ActionLogger.log("admin_forces_authorization", current_user, user, nil, handler: workflow.name, user_id: user.id, handler_name: workflow.fullname,
                                                                                           reason: force_verification)
        end

        def destroy_authorization
          if authorization&.destroy
            Decidim::ActionLogger.log("admin_destroys_authorization", current_user, user, nil, user_id: user.id, handler: workflow.name, handler_name: workflow.fullname)
          end
        end

        def json_error(exception)
          render json: render_to_string(partial: "callout", locals: { message: exception.message, klass: "alert" }), status: :unprocessable_entity
        end

        def user
          @user ||= Decidim::User.find(params[:id])
        end

        def authorization
          @authorization ||= Decidim::Authorization.where.not(granted_at: nil).find_by(user: user, name: workflow.name)
        end

        def granted?
          authorization&.reload.present?
        rescue ActiveRecord::RecordNotFound
          false
        end

        def workflow
          @workflow ||= Decidim::Verifications.find_workflow_manifest(params[:handler])
        end

        def handler
          @handler ||= Decidim::AuthorizationHandler.handler_for(params[:handler], handler_params)
        end

        def conflict
          @conflict ||= Decidim::Authorization.find_by(unique_id: handler.unique_id)
        end

        def handler_params
          (params[:authorization_handler] || {}).merge(user: USER)
        end

        def force_verification
          @force_verification ||= params[:force_verification].to_s.strip.presence
        end
      end
    end
  end
end
