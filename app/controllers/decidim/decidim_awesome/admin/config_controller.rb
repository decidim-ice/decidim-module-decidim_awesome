# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      # Global configuration controller
      class ConfigController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig
        include ConfigConstraintsHelpers
        helper ConfigConstraintsHelpers

        helper_method :constraints_for, :users_for, :config_var, :available_authorizations
        before_action do
          enforce_permission_to :edit_config, configs
        end

        def show
          @form = form(ConfigForm).from_params(organization_awesome_config)

          redirect_to decidim_admin_decidim_awesome.checks_maintenance_index_path unless config_var
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
                render json: query.all.collect { |u|
                               {
                                 value: u.id,
                                 text: format_user_name(u),
                                 is_admin: u.read_attribute("admin")
                               }
                             }
              else
                render json: []
              end
            end
          end
        end

        def rename_scope_label
          RenameScopeLabel.call(params, current_organization) do
            on(:ok) do |result|
              render json: result.merge({
                                          html: render_to_string(partial: "decidim/decidim_awesome/admin/config/constraints",
                                                                 locals: {
                                                                   key: result[:scope],
                                                                   constraints: constraints_for(result[:scope])
                                                                 })
                                        })
            end

            on(:invalid) do |message|
              render json: { error: message }, status: :unprocessable_entity
            end
          end
        end

        private

        def config_var
          return params[:var] if menus.has_key?(params[:var].try(:to_sym))

          menus.key(true)
        end

        def constraints_for(key)
          awesome_config_instance.setting_for(key)&.constraints
        end

        def configs
          return params[:config].keys if params.has_key?(:config)

          DecidimAwesome.config.keys
        end

        def users_for(ids_list)
          Decidim::User.where(id: ids_list).map { |user| [format_user_name(user), user.id, { data: { is_admin: user.read_attribute("admin") } }] }
        end

        def format_user_name(user)
          "#{user.name} (@#{user.nickname} - #{user.email})"
        end

        def available_authorizations
          @available_authorizations ||= Decidim::Verifications::Adapter.from_collection(
            current_organization.available_authorization_handlers
          )
        end
      end
    end
  end
end
