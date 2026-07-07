# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class AwesomeAuthorizationsController < DecidimAwesome::Admin::ApplicationController
        helper ConfigConstraintsHelpers
        helper_method :available?, :authorization_groups

        before_action do
          enforce_permission_to :edit_config, :awesome_authorization_handler
        end

        def index; end

        def edit
          @form = form(AwesomeAuthorizationGroupForm).from_model(authorization_group)
        end

        def new
          @form = form(AwesomeAuthorizationGroupForm).instance
        end

        def create
          @form = form(AwesomeAuthorizationGroupForm).from_params(params)

          CreateAwesomeAuthorizationGroup.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("decidim.decidim_awesome.admin.awesome_authorizations.create.success")
              redirect_to decidim_admin_decidim_awesome.awesome_authorizations_path
            end

            on(:invalid) do |error|
              flash.now[:alert] = I18n.t("decidim.decidim_awesome.admin.awesome_authorizations.create.error", error:)
              render :new
            end
          end
        end

        def update
          @form = form(AwesomeAuthorizationGroupForm).from_params(params)

          UpdateAwesomeAuthorizationGroup.call(@form, authorization_group) do
            on(:ok) do
              flash[:notice] = I18n.t("decidim.decidim_awesome.admin.awesome_authorizations.update.success")
              redirect_to decidim_admin_decidim_awesome.awesome_authorizations_path
            end

            on(:invalid) do |error|
              flash.now[:alert] = I18n.t("decidim.decidim_awesome.admin.awesome_authorizations.update.error", error:)
              render :edit
            end
          end
        end

        def destroy
          users_to_sync = authorization_group.granted_in_group.to_a

          authorization_group.destroy!
          users_to_sync.each do |user|
            Decidim::DecidimAwesome::SyncAwesomeAuthorizationUserJob.perform_later(user.id)
          end

          flash[:notice] = I18n.t("decidim.decidim_awesome.admin.awesome_authorizations.destroy.success")
          redirect_to decidim_admin_decidim_awesome.awesome_authorizations_path
        end

        def sync
          Decidim::DecidimAwesome::SyncAwesomeAuthorizationGroupJob.perform_later(authorization_group.id)
          flash[:notice] = I18n.t("decidim.decidim_awesome.admin.awesome_authorizations.sync.success")
          redirect_to decidim_admin_decidim_awesome.awesome_authorizations_path
        end

        private

        def available?
          @available ||= current_organization.available_authorizations.include?("awesome_authorization_handler")
        end

        def authorization_groups
          @authorization_groups ||= current_organization.awesome_authorization_groups
        end

        def authorization_group
          @authorization_group ||= authorization_groups.find(params[:id])
        end
      end
    end
  end
end
