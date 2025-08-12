# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class LoginAuthorizationService
      PARAM_HANDLER_KEYS = [:access_authorization_handlers, :content_authorization_handlers, :contextual_handlers].freeze

      def initialize(controller)
        @controller = controller
      end

      def login_authorization_required?
        user_signed_in_ok? && !allowed_controller? && !from_required_authorizations_page?
      end

      def skip_access_authorization_check?
        !login_authorization_required? || from_required_authorizations_page? || required_authorizations.present?
      end

      def required_authorizations
        return @required_authorizations if defined?(@required_authorizations)

        names = if from_required_authorizations_page? && (raw = first_present_param_value).present?
                  normalize_names(raw.to_s.split(","))
                else
                  normalize_names(always_group_handler_names)
                end

        filtered = filter_allowed_authorizations(names)
        @required_authorizations = Decidim::Verifications::Adapter.from_collection(filtered)
      end

      def user_is_authorized?
        return true if required_authorizations.blank?

        awesome_config[:force_authorization_with_any_method] ? current_authorizations.any? : current_authorizations.count == required_authorizations.count
      end

      def access_authorization_handlers
        ctx = detect_context
        return [] if ctx.blank?

        groups = ctx.is_a?(Decidim::Component) ? group_service.groups_for_component(ctx) : group_service.groups_for_space(ctx)
        names = normalize_names(groups.flat_map { |g| g[:handlers] })
        filter_allowed_authorizations(names)
      end

      def user_has_handlers?(handlers)
        (Array(handlers).compact_blank - granted_authorization_names).empty?
      end

      def redirect_path_with_handlers(handlers)
        controller.decidim_decidim_awesome.required_authorizations_path(
          redirect_url: controller.request.fullpath,
          access_authorization_handlers: Array(handlers).join(",")
        )
      end

      def localized_required_authorizations_fullnames
        required_authorizations.map(&:fullname).join(", ")
      end

      private

      attr_reader :controller

      def awesome_config
        controller.awesome_config
      end

      def group_service
        @group_service ||= Decidim::DecidimAwesome::AuthorizationGroupService.new(controller.current_organization)
      end

      def available_workflow_names
        @available_workflow_names ||= Decidim.authorization_workflows.map(&:name)
      end

      def organization_available_authorizations
        @organization_available_authorizations ||= Array(controller.current_organization.available_authorizations)
      end

      def granted_authorization_names
        @granted_authorization_names ||= Decidim::Verifications::Authorizations.new(
          organization: controller.current_organization,
          user: controller.current_user,
          granted: true
        ).map(&:name)
      end

      def required_authorization_names
        @required_authorization_names ||= required_authorizations.map(&:name)
      end

      def current_authorizations
        @current_authorizations ||= Decidim::Verifications::Authorizations.new(
          organization: controller.current_organization,
          user: controller.current_user,
          name: required_authorization_names,
          granted: true
        )
      end

      def always_group_handler_names
        group_service.always_groups.flat_map { |g| g[:handlers] }
      end

      def first_present_param_value
        PARAM_HANDLER_KEYS.each { |k| return controller.params[k] if controller.params[k].present? }
        nil
      end

      def normalize_names(list)
        Array(list).map { |h| h.is_a?(Array) ? h.first : h }.compact_blank
      end

      def filter_allowed_authorizations(handlers)
        Array(handlers) & organization_available_authorizations & available_workflow_names
      end

      def detect_context
        detect_from_helpers || detect_from_ivars || detect_from_params
      end

      def detect_from_helpers
        [:current_component, :current_participatory_space, :current_assembly].each do |m|
          return controller.public_send(m) if controller.respond_to?(m) && controller.public_send(m).present?
        end
        nil
      end

      def detect_from_ivars
        [:@group, :@participatory_process_group].each do |ivar|
          return controller.instance_variable_get(ivar) if controller.instance_variable_defined?(ivar) && controller.instance_variable_get(ivar).present?
        end
        nil
      end

      def detect_from_params
        comp = (id = controller.params[:component_id]).present? ? Decidim::Component.find_by(id: id) : nil
        return comp if comp

        p = controller.params
        cn = controller.controller_name

        return Decidim::Assembly.find_by(slug: p[:slug]) if cn == "assemblies" && p[:slug].present?
        return Decidim::ParticipatoryProcess.find_by(slug: p[:slug]) if cn == "participatory_processes" && p[:slug].present?
        return Decidim::ParticipatoryProcessGroup.find_by(id: p[:id]) if cn == "participatory_process_groups" && p[:id].present?

        nil
      end

      # Allowed controllers / page guards

      def user_signed_in_ok?
        controller.user_signed_in? && controller.current_user.confirmed? && !controller.current_user.blocked?
      end

      def allowed_controller?
        allowed_controllers.include?(controller.controller_name)
      end

      def from_required_authorizations_page?
        controller.request.path.start_with?(controller.decidim_decidim_awesome.required_authorizations_path)
      end

      def allowed_controllers
        %w(required_authorizations authorizations upload_validations timeouts editor_images locales pages tos) + awesome_config[:force_authorization_allowed_controller_names].to_a
      end
    end
  end
end
