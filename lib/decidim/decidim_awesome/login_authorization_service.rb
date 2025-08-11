# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # Encapsulates the logic for determining and enforcing login-time authorizations.
    # This service is instantiated with a controller so it can read the current
    # request, params and helper methods, following Decidim patterns of
    # thin controllers/concerns and extracted services.
    class LoginAuthorizationService
      def initialize(controller)
        @controller = controller
      end

      # Public API
      def login_authorization_required?
        controller.user_signed_in? &&
          controller.current_user.confirmed? &&
          !controller.current_user.blocked? &&
          !allowed_controller? &&
          !from_required_authorizations_page?
      end

      def skip_contextual_check?
        !login_authorization_required? ||
          from_required_authorizations_page? ||
          required_authorizations.present?
      end

      def required_authorizations
        return @required_authorizations if defined?(@required_authorizations)

        allowed = if from_required_authorizations_page? && controller.params[:contextual_handlers].present?
                    contextual = controller.params[:contextual_handlers].to_s.split(",").map(&:strip).compact_blank
                    filter_allowed_authorizations(contextual)
                  else
                    service = Decidim::DecidimAwesome::AuthorizationGroupService.new(controller.current_organization)
                    handlers = service.always_groups.flat_map { |g| g[:handlers] }.compact_blank
                    filter_allowed_authorizations(handlers)
                  end

        @required_authorizations = Decidim::Verifications::Adapter.from_collection(Array(allowed))
      end

      def user_is_authorized?
        return true if required_authorizations.blank?

        authorizations = current_authorizations
        if awesome_config[:force_authorization_with_any_method]
          authorizations.any?
        else
          authorizations.count == required_authorizations.count
        end
      end

      def contextual_handlers
        context = detect_context
        return [] if context.blank?

        groups = contextual_groups_for(context)
        raw = groups.flat_map { |g| Array(g[:handlers]) }
        names = raw.map { |h| h.is_a?(Array) ? h.first : h }.compact_blank
        filter_allowed_authorizations(names)
      end

      def user_has_handlers?(handlers)
        authorized = Decidim::Verifications::Authorizations.new(
          organization: controller.current_organization,
          user: controller.current_user,
          granted: true
        ).map(&:name)

        (handlers - authorized).empty?
      end

      def redirect_path_with_handlers(handlers)
        controller.decidim_decidim_awesome.required_authorizations_path(
          redirect_url: controller.request.fullpath,
          contextual_handlers: handlers.join(",")
        )
      end

      # Helpers exposed for the concern to format messages
      def localized_required_authorizations_fullnames
        required_authorizations.map(&:fullname).join(", ")
      end

      private

      attr_reader :controller

      def awesome_config
        controller.awesome_config
      end

      def current_authorizations
        @current_authorizations ||= Decidim::Verifications::Authorizations.new(
          organization: controller.current_organization,
          user: controller.current_user,
          name: required_authorizations.map(&:name),
          granted: true
        )
      end

      def contextual_groups_for(context)
        service = Decidim::DecidimAwesome::AuthorizationGroupService.new(controller.current_organization)
        context.is_a?(Decidim::Component) ? service.groups_for_component(context) : service.groups_for_space(context)
      end

      # Context detection
      def detect_context
        detect_from_helpers || detect_from_ivars || detect_from_params || nil
      end

      def detect_from_helpers
        [:current_component, :current_participatory_space, :current_assembly].each do |method|
          return controller.public_send(method) if controller.respond_to?(method) && controller.public_send(method).present?
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
        detect_component_from_params ||
          detect_assembly_from_params ||
          detect_participatory_process_from_params ||
          detect_process_group_from_params
      end

      def detect_component_from_params
        return if controller.params[:component_id].blank?

        Decidim::Component.find_by(id: controller.params[:component_id])
      end

      def detect_assembly_from_params
        p = controller.params
        cn = controller.controller_name
        return Decidim::Assembly.find_by(slug: p[:assembly_slug]) if p[:assembly_slug].present?
        return Decidim::Assembly.find_by(slug: p[:assembly_id]) if p[:assembly_id].present?
        return Decidim::Assembly.find_by(slug: p[:slug]) if cn == "assemblies" && p[:slug].present?
        return Decidim::Assembly.find_by(slug: p[:id]) if cn == "assemblies" && p[:id].present?

        nil
      end

      def detect_participatory_process_from_params
        p = controller.params
        cn = controller.controller_name
        return Decidim::ParticipatoryProcess.find_by(slug: p[:participatory_process_slug]) if p[:participatory_process_slug].present?
        return Decidim::ParticipatoryProcess.find_by(slug: p[:slug]) if cn == "participatory_processes" && p[:slug].present?
        return Decidim::ParticipatoryProcess.find_by(slug: p[:id]) if cn == "participatory_processes" && p[:id].present?

        nil
      end

      def detect_process_group_from_params
        return unless controller.controller_name == "participatory_process_groups" && controller.params[:id].present?

        Decidim::ParticipatoryProcessGroup.find_by(id: controller.params[:id])
      end

      # Allowed controllers and paths
      def allowed_controller?
        allowed_controllers.include?(controller.controller_name)
      end

      def from_required_authorizations_page?
        controller.request.path.start_with?(controller.decidim_decidim_awesome.required_authorizations_path)
      end

      def allowed_controllers
        %w(required_authorizations authorizations upload_validations timeouts editor_images locales pages tos) + awesome_config[:force_authorization_allowed_controller_names].to_a
      end

      def filter_allowed_authorizations(handlers)
        Array(handlers) & Array(controller.current_organization.available_authorizations) & Decidim.authorization_workflows.map(&:name)
      end
    end
  end
end
