# frozen_string_literal: true

require "csv"

module Decidim
  module DecidimAwesome
    module Admin
      class AwesomeAuthorizationUsersController < DecidimAwesome::Admin::ApplicationController
        include Decidim::Admin::Filterable
        helper ConfigConstraintsHelpers

        before_action do
          enforce_permission_to :edit_config, :awesome_authorization_handler
        end

        helper_method :authorization_group, :authorization_members

        def index; end

        def new
          @form = form(AwesomeAuthorizationMembersForm).instance
        end

        def create
          @form = form(AwesomeAuthorizationMembersForm).from_params(params, authorization_group:)

          CreateAwesomeAuthorizationMembers.call(@form) do
            on(:ok) do |created_count|
              Decidim::DecidimAwesome::SyncAwesomeAuthorizationGroupJob.perform_later(authorization_group.id)
              flash[:notice] = I18n.t("decidim.decidim_awesome.admin.awesome_authorization_users.create.success", count: created_count)
              redirect_to decidim_admin_decidim_awesome.awesome_authorization_users_path(authorization_group)
            end

            on(:invalid) do |error|
              flash.now[:alert] = I18n.t("decidim.decidim_awesome.admin.awesome_authorization_users.create.error", error: error)
              render :new
            end
          end
        end

        def destroy
          Decidim::DecidimAwesome::SyncAwesomeAuthorizationGroupJob.perform_later(authorization_group.id)
          authorization_group.members.find(params[:id]).destroy!
          flash[:notice] = I18n.t("decidim.decidim_awesome.admin.awesome_authorization_users.destroy.success")
          redirect_to decidim_admin_decidim_awesome.awesome_authorization_users_path(authorization_group)
        end

        private

        def base_query
          authorization_group.members.order(:email)
        end

        def authorization_group
          @authorization_group ||= current_organization.awesome_authorization_groups.find(params[:awesome_authorization_id])
        end

        def authorization_members
          @authorization_members ||= paginate(base_query)
        end
      end
    end
  end
end
