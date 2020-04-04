# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      # Constraints configuration controller for config keys
      class ConstraintsController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig
        include ConfigConstraintsHelpers

        layout false

        helper_method :participatory_space_manifests, :translate_constraint_value

        def new
          @form = form(ConstraintForm).instance(setting: current_setting)
        end

        def show
          @form = form(ConstraintForm).from_params(constraint.settings)
        end

        def create
          @form = form(ConstraintForm).from_params(params, setting: current_setting)
          CreateConstraint.call(@form) do
            on(:ok) do |constraint|
              render json: {
                id: constraint.id,
                key: current_setting.var,
                message: I18n.t("decidim_awesome.admin.constraints.create.success", scope: "decidim"),
                html: render_to_string(partial: "decidim/decidim_awesome/admin/editors/constraints",
                                       locals: {
                                         key: current_setting.var,
                                         constraints: current_setting.constraints
                                       })
              }
            end

            on(:invalid) do |message|
              render json: {
                id: params[:id],
                key: current_setting.var,
                message: I18n.t("decidim_awesome.admin.constraints.create.error", scope: "decidim"),
                error: message
              },
                     status: :unprocessable_entity
            end
          end
        end

        def update
          @form = form(ConstraintForm).from_params(params)
          UpdateConstraint.call(@form) do
            on(:ok) do
              render json: {
                id: params[:id],
                key: constraint.awesome_config.var,
                message: I18n.t("decidim_awesome.admin.constraints.update.success", scope: "decidim"),
                html: render_to_string(partial: "decidim/decidim_awesome/admin/editors/constraints",
                                       locals: {
                                         key: constraint.awesome_config.var,
                                         constraints: constraint.awesome_config.constraints
                                       })
              }
            end

            on(:invalid) do |message|
              render json: {
                id: params[:id],
                key: constraint.awesome_config.var,
                message: I18n.t("decidim_awesome.admin.constraints.update.error", scope: "decidim"),
                error: message
              },
                     status: :unprocessable_entity
            end
          end
        end

        def destroy
          DestroyConstraint.call(constraint) do
            on(:ok) do
              render json: {
                id: params[:id],
                key: constraint.awesome_config.var,
                message: I18n.t("decidim_awesome.admin.constraints.destroy.success", scope: "decidim"),
                html: render_to_string(partial: "decidim/decidim_awesome/admin/editors/constraints",
                                       locals: {
                                         key: constraint.awesome_config.var,
                                         constraints: constraint.awesome_config.constraints
                                       })
              }
            end

            on(:invalid) do |message|
              render json: {
                id: params[:id],
                key: constraint.awesome_config.var,
                message: I18n.t("decidim_awesome.admin.constraints.destroy.error", scope: "decidim"),
                error: message
              },
                     status: :unprocessable_entity
            end
          end
        end

        private

        def constraint
          @constraint ||= ConfigConstraint.find(params[:id])
        end

        def current_setting
          awesome_config_instance.setting_for params[:key]
        end
      end
    end
  end
end
