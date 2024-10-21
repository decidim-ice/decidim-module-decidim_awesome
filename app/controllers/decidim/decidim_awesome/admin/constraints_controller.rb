# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      # Constraints configuration controller for config keys
      class ConstraintsController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig
        include Decidim::Headers::HttpCachingDisabler
        helper ConfigConstraintsHelpers

        layout false
        helper_method :constraint_key

        before_action do
          render :no_permissions unless allowed_to? :edit_config, constraint_key
        end

        def show
          @form = form(ConstraintForm).from_params(constraint.settings.merge(filtered_params))
        end

        def new
          @form = form(ConstraintForm).from_params(filtered_params, setting: current_setting)
        end

        def create
          @form = form(ConstraintForm).from_params(params, setting: current_setting)
          CreateConstraint.call(@form) do
            on(:ok) do |constraint|
              render json: {
                id: constraint.id,
                key: current_setting.var,
                message: I18n.t("decidim_awesome.admin.constraints.create.success", scope: "decidim"),
                html: render_to_string(partial: "decidim/decidim_awesome/admin/config/constraints",
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
                html: render_to_string(partial: "decidim/decidim_awesome/admin/config/constraints",
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
                html: render_to_string(partial: "decidim/decidim_awesome/admin/config/constraints",
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

        def filtered_params
          ops = {}
          [:participatory_space_manifest, :participatory_space_slug].each do |key|
            ops[key] = params[key] if params[key]
          end
          ops
        end

        def constraint
          @constraint ||= ConfigConstraint.find(params[:id])
        end

        def current_setting
          awesome_config_instance.setting_for params[:key]
        end

        def constraint_key
          key = params[:key] || constraint.awesome_config.var
          case key
          when /^scoped_style_/
            :scoped_styles
          when /^scoped_admin_style_/
            :scoped_admin_styles
          when /^scoped_admin_/
            :scoped_admins
          when /^proposal_custom_field_/
            :proposal_custom_fields
          when /^proposal_private_custom_field_/
            :proposal_private_custom_fields
          else
            key
          end
        end
      end
    end
  end
end
