# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module CheckLoginAuthorizations
      extend ActiveSupport::Concern

      included do
        include ::Decidim::DecidimAwesome::NeedsAwesomeConfig

        before_action :check_required_login_authorizations
        before_action :check_contextual_login_authorizations
      end

      private

      def check_required_login_authorizations
        return unless login_authorization_required?
        return if user_is_authorized?

        flash[:alert] = I18n.t("decidim.decidim_awesome.session.authorization_is_required",
                               authorizations: required_authorizations.map(&:fullname).join(", "))
        redirect_to decidim_decidim_awesome.required_authorizations_path(redirect_url: request.fullpath)
      end

      def check_contextual_login_authorizations
        return if skip_contextual_check?

        context = detect_context
        return if context.blank?

        groups = contextual_groups_for(context)
        handlers = contextual_handlers_from_groups(groups)
        return if handlers.blank? || user_has_handlers?(handlers)

        redirect_to_required_with_handlers(handlers)
      end

      def login_authorization_required?
        user_signed_in? &&
          current_user.confirmed? &&
          !current_user.blocked? &&
          !allowed_controller? &&
          !from_required_authorizations_page?
      end

      def skip_contextual_check?
        !login_authorization_required? ||
          from_required_authorizations_page? ||
          required_authorizations.present?
      end

      def contextual_groups_for(context)
        service = Decidim::DecidimAwesome::AuthorizationGroupService.new(current_organization)
        context.is_a?(Decidim::Component) ? service.groups_for_component(context) : service.groups_for_space(context)
      end

      def contextual_handlers_from_groups(groups)
        filter_allowed_authorizations(groups.flat_map { |g| g[:handlers] }.compact_blank)
      end

      def redirect_to_required_with_handlers(handlers)
        required = Decidim::Verifications::Adapter.from_collection(handlers)
        flash[:alert] = I18n.t("decidim.decidim_awesome.session.authorization_is_required",
                               authorizations: required.map(&:fullname).join(", "))
        redirect_to decidim_decidim_awesome.required_authorizations_path(
          redirect_url: request.fullpath,
          contextual_handlers: handlers.join(",")
        )
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
        @required_authorizations ||= if from_required_authorizations_page? && params[:contextual_handlers].present?
                                       contextual = params[:contextual_handlers].to_s.split(",").map(&:strip).reject(&:blank?)
                                       allowed = filter_allowed_authorizations(contextual)
                                       Decidim::Verifications::Adapter.from_collection(allowed)
                                     else
                                       service = Decidim::DecidimAwesome::AuthorizationGroupService.new(current_organization)
                                       handlers = service.always_groups.flat_map { |g| g[:handlers] }.compact_blank
                                       allowed = filter_allowed_authorizations(handlers)
                                       Decidim::Verifications::Adapter.from_collection(allowed)
                                     end

      end

      def current_authorizations
        @current_authorizations ||= Decidim::Verifications::Authorizations.new(
          organization: current_organization,
          user: current_user,
          name: required_authorizations.map(&:name),
          granted: true
        )
      end

      def user_has_handlers?(handlers)
        authorized = Decidim::Verifications::Authorizations.new(
          organization: current_organization,
          user: current_user,
          granted: true
        ).map(&:name)

        (handlers - authorized).empty?
      end

      def detect_context
        detect_from_helpers || detect_from_ivars || detect_from_params || detect_from_controller
      end

      def detect_from_helpers
        [:current_component, :current_participatory_space, :current_assembly].each do |method|
          return send(method) if respond_to?(method) && send(method).present?
        end
        nil
      end

      def detect_from_ivars
        [:@group, :@participatory_process_group].each do |ivar|
          return instance_variable_get(ivar) if instance_variable_defined?(ivar) && instance_variable_get(ivar).present?
        end
        nil
      end

      def detect_from_params
        detect_component_from_params ||
          detect_assembly_from_params ||
          detect_participatory_process_from_params ||
          detect_process_group_from_params
      end

      def detect_component_from_params
        return if params[:component_id].blank?

        Decidim::Component.find_by(id: params[:component_id])
      end

      def detect_assembly_from_params
        return Decidim::Assembly.find_by(slug: params[:assembly_slug]) if params[:assembly_slug].present?
        return Decidim::Assembly.find_by(slug: params[:assembly_id]) if params[:assembly_id].present?
        return Decidim::Assembly.find_by(slug: params[:slug]) if controller_name == "assemblies" && params[:slug].present?
        return Decidim::Assembly.find_by(slug: params[:id]) if controller_name == "assemblies" && params[:id].present?

        nil
      end

      def detect_participatory_process_from_params
        return Decidim::ParticipatoryProcess.find_by(slug: params[:participatory_process_slug]) if params[:participatory_process_slug].present?
        return Decidim::ParticipatoryProcess.find_by(slug: params[:slug]) if controller_name == "participatory_processes" && params[:slug].present?
        return Decidim::ParticipatoryProcess.find_by(slug: params[:id]) if controller_name == "participatory_processes" && params[:id].present?

        nil
      end

      def detect_process_group_from_params
        return unless controller_name == "participatory_process_groups" && params[:id].present?

        Decidim::ParticipatoryProcessGroup.find_by(id: params[:id])
      end

      def detect_from_controller
        # Do not create empty instances which would prevent matching slug-based constraints.
        # If a specific context cannot be detected from helpers, ivars or params, return nil.
        nil
      end

      def allowed_controller?
        allowed_controllers.include?(controller_name)
      end

      def from_required_authorizations_page?
        request.path.start_with?(decidim_decidim_awesome.required_authorizations_path)
      end

      def allowed_controllers
        %w(required_authorizations authorizations upload_validations timeouts editor_images locales pages tos) + awesome_config[:force_authorization_allowed_controller_names].to_a
      end

      def filter_allowed_authorizations(handlers)
        handlers & current_organization.available_authorizations & Decidim.authorization_workflows.map(&:name)
      end
    end
  end
end
