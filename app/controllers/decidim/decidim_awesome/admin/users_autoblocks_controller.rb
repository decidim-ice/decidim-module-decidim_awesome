# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      # Autoblock users admin controller
      class UsersAutoblocksController < DecidimAwesome::Admin::ConfigController
        include ConfigConstraintsHelpers

        helper_method :types_options, :current_rules

        layout "decidim/decidim_awesome/admin/application"

        def index
          load_calculations

          @config_form = form(UsersAutoblocksConfigForm).from_model(current_config)
        end

        def new
          @form = form(UsersAutoblocksForm).instance
        end

        def edit
          @form = form(UsersAutoblocksForm).from_model(users_autoblock_rule)
        end

        def create
          @form = form(UsersAutoblocksForm).from_params(params)

          CreateUsersAutoblockRule.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("success", scope: "decidim.decidim_awesome.admin.users_autoblocks.create")
              remove_calculations_file

              redirect_to decidim_admin_decidim_awesome.users_autoblocks_path
            end

            on(:invalid) do |message|
              flash.now[:alert] = I18n.t("error", error: message, scope: "decidim.decidim_awesome.admin.users_autoblocks.create")
              render :new
            end
          end
        end

        def update
          @form = form(UsersAutoblocksForm).from_params(params)
          UpdateUsersAutoblockRule.call(@form, users_autoblock_rule) do
            on(:ok) do
              flash[:notice] = I18n.t("success", scope: "decidim.decidim_awesome.admin.users_autoblocks.update")
              remove_calculations_file

              redirect_to decidim_admin_decidim_awesome.users_autoblocks_path
            end

            on(:invalid) do |message|
              flash.now[:alert] = I18n.t("error", error: message, scope: "decidim.decidim_awesome.admin.users_autoblocks.update")
              render :new
            end
          end
        end

        def destroy
          DestroyUsersAutoblockRule.call(users_autoblock_rule, current_organization) do
            on(:ok) do
              flash[:notice] = I18n.t("success", scope: "decidim.decidim_awesome.admin.users_autoblocks.destroy")
              remove_calculations_file
            end

            on(:invalid) do |message|
              flash[:alert] = I18n.t("error", error: message, scope: "decidim.decidim_awesome.admin.users_autoblocks.destroy")
            end
          end

          redirect_to decidim_admin_decidim_awesome.users_autoblocks_path
        end

        def detect_and_run
          @config_form = form(UsersAutoblocksConfigForm).from_params(params)

          AutoblockUsers.call(@config_form) do
            on(:ok) do |count|
              flash[:notice] = I18n.t("success", count:, scope: "decidim.decidim_awesome.admin.users_autoblocks.detect_and_run")
            end

            on(:invalid) do |message|
              flash[:alert] = I18n.t("error", error: message, scope: "decidim.decidim_awesome.admin.users_autoblocks.detect_and_run")
            end
          end

          redirect_to decidim_admin_decidim_awesome.users_autoblocks_path
        end

        def calculate_scores
          exporter = Decidim::DecidimAwesome::UsersAutoblocksScoresExporter.new(Decidim::User.where(blocked: false))
          exporter.export

          flash[:notice] = I18n.t("success", scope: "decidim.decidim_awesome.admin.users_autoblocks.calculate_scores")
          redirect_to decidim_admin_decidim_awesome.users_autoblocks_path
        end

        private

        def types_options
          Decidim::DecidimAwesome::UserAutoblockScoresPresenter::USERS_AUTOBLOCKS_TYPES.keys.index_by do |key|
            I18n.t(key, scope: "decidim.decidim_awesome.admin.users_autoblocks.form.types")
          end
        end

        def current_rules
          @current_rules ||= (AwesomeConfig.find_by(var: :users_autoblocks, organization: current_organization)&.value || [])
        end

        def current_config
          @current_config ||= OpenStruct.new(AwesomeConfig.find_by(var: :users_autoblocks_config, organization: current_organization)&.value || {})
        end

        def users_autoblock_rule
          rule = current_rules.find { |r| md5(r.to_json) == params[:id] }
          raise ActiveRecord::RecordNotFound if rule.blank?

          OpenStruct.new(rule)
        end

        def calculations_path
          @calculations_path ||= File.join(Rails.application.root, Decidim::DecidimAwesome::UsersAutoblocksScoresExporter::DATA_FILE_PATH)
        end

        def remove_calculations_file
          return unless File.exist?(calculations_path)

          File.delete(calculations_path)
        end

        def load_calculations
          @scores_counts = {}
          return unless File.exist?(calculations_path)

          calculations = CSV.read(calculations_path, headers: true, col_sep: ";")
          rules_headers = calculations.headers.grep(/ - \d+/)
          counts = rules_headers.index_with { |rule_header| calculations.count { |row| row[rule_header].to_i.positive? } }
          @scores_counts = counts.transform_keys { |k| k.split(" - ").last.to_i }
        end
      end
    end
  end
end
