# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      # Global configuration controller
      class ConfigController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig
        include ConfigConstraintsHelpers
        helper ConfigConstraintsHelpers

        layout "decidim/admin/decidim_awesome"

        helper_method :constraints_for, :users_for
        before_action do
          enforce_permission_to :edit_config, configs
        end

        def show
          @form = form(ConfigForm).from_params(organization_awesome_config)
        end

        def update
          @form = form(ConfigForm).from_params(params[:config])
          UpdateConfig.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("config.update.success", scope: "decidim.decidim_awesome.admin")
              redirect_to decidim_admin_decidim_awesome.config_path
            end

            on(:invalid) do |message, err|
              flash.now[:alert] = I18n.t("config.update.error", error: message, scope: "decidim.decidim_awesome.admin")
              render :show, locals: { errors: err.presence }
            end
          end
        end

        def users
          respond_to do |format|
            format.json do
              if (term = params[:term].to_s).present?
                query = current_organization.users.order(name: :asc)
                query = query.where("name ILIKE :term OR nickname ILIKE :term OR email ILIKE :term", term: "%#{term}%")

                render json: query.all.collect { |u| { id: u.id, text: format_user_name(u) } }
              else
                render json: []
              end
            end
          end
        end

        private

        def constraints_for(key)
          awesome_config_instance.setting_for(key)&.constraints
        end

        def configs
          return params[:config].keys if params.has_key?(:config)

          DecidimAwesome.config.keys
        end

        def users_for(ids_list)
          Decidim::User.where(id: ids_list).map { |user| OpenStruct.new(text: format_user_name(user), id: user.id) }
        end

        def format_user_name(user)
          "<span class='#{"is-admin" if user.admin}'>#{user.name} (@#{user.nickname} - #{user.email})</span>"
        end
      end
    end
  end
end
