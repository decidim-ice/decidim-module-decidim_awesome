# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module CheckLoginAuthorizations
      extend ActiveSupport::Concern

      included do
        include ::Decidim::DecidimAwesome::NeedsAwesomeConfig
        before_action :check_required_login_authorizations
      end

      private

      def check_required_login_authorizations
        return unless user_signed_in?
        return unless current_user.confirmed?
        return if current_user.blocked?
        return if allowed_controllers.include?(controller_name)

        unless user_is_authorized?
          flash[:alert] = I18n.t("decidim.decidim_awesome.session.authorization_is_required",
                                 authorizations: required_authorizations.map(&:fullname).join(", "))
          redirect_to decidim_decidim_awesome.required_authorizations_path(redirect_url: request.fullpath)
        end
      end

      def user_is_authorized?
        return true if required_authorizations.blank?

        @user_is_authorized ||= if awesome_config[:force_authorization_with_any_method]
                                  current_authorizations.any?
                                else
                                  current_authorizations.count == required_authorizations.count
                                end
      end

      def required_authorizations
        return @required_authorizations if defined?(@required_authorizations)

        handlers = authorization_handlers_without_constraints
        allowed_handlers = filter_allowed_authorizations(handlers)
        @required_authorizations = Decidim::Verifications::Adapter.from_collection(allowed_handlers)
      end

      def authorization_handlers_without_constraints
        config = Decidim::DecidimAwesome::AwesomeConfig.find_by(
          var: "authorization_groups",
          organization: current_organization
        )
        return [] unless config&.value.is_a?(Hash)

        config.value.flat_map do |group_key, group_data|
          handlers = Array(group_data["authorization_handlers"]).compact_blank
          next [] if handlers.empty?
          next [] if group_has_constraints?(group_key)

          handlers
        end.uniq
      end

      def group_has_constraints?(group_key)
        group_config = Decidim::DecidimAwesome::AwesomeConfig.find_by(
          var: "authorization_group_#{group_key}",
          organization: current_organization
        )
        Decidim::DecidimAwesome::ConfigConstraint.exists?(decidim_awesome_config_id: group_config&.id)
      end

      def filter_allowed_authorizations(handlers)
        handlers & current_organization.available_authorizations & Decidim.authorization_workflows.map(&:name)
      end

      def current_authorizations
        @current_authorizations ||= Decidim::Verifications::Authorizations.new(
          organization: current_organization,
          user: current_user,
          name: required_authorizations.map(&:name),
          granted: true
        )
      end

      def allowed_controllers
        %w(required_authorizations authorizations upload_validations timeouts editor_images locales pages tos) + awesome_config[:force_authorization_allowed_controller_names].to_a
      end
    end
  end
end
