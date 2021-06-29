# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # A middleware that stores the current awesome context by parsing the request
    class CurrentConfig
      # Initializes the Rack Middleware.
      #
      # app - The Rack application
      def initialize(app)
        @app = app
      end

      # Main entry point for a Rack Middleware.
      #
      # env - A Hash.
      def call(env)
        @request = Rack::Request.new(env)
        if @request.env["decidim.current_organization"]
          @config = awesome_config_instance
          env["decidim_awesome.current_config"] = @config
          tamper_user_model(env)

        end

        @app.call(env)
      end

      private

      def awesome_config_instance
        @awesome_config_instance ||= Config.new @request.env["decidim.current_organization"]
        @awesome_config_instance.context_from_request @request
        @awesome_config_instance
      end

      def tamper_user_model(env)
        return unless Decidim::User.respond_to? :awesome_admins_for_current_scope

        Decidim::User.awesome_admins_for_current_scope = if safe_get_route? || safe_post_route?
                                                           potential_admins
                                                         else
                                                           valid_admins(env)
                                                         end
        # TODO: redirect to /admin if is an admin page, and no admins found
      end

      def potential_admins
        @config.collect_sub_configs("scoped_admin") do |subconfig|
          subconfig&.constraints&.detect { |c| c.settings["participatory_space_manifest"] == "none" } ? false : true
        end.flatten.uniq.map(&:to_i)
      end

      def valid_admins(_env)
        @config.collect_sub_configs("scoped_admin") do |subconfig|
          # allow index controllers if scoped to a subspace/component
          valid_in_get_context?(subconfig&.constraints)
        end.flatten.uniq.map(&:to_i)
      end

      def safe_get_route?
        return unless @request.get?

        case @request.path
        when "/admin/"
          true
        when %r{^/admin/admin_terms}
          true
        when %r{^/(?!admin/)} # not starting with "/admin/"
          true
        end
      end

      def safe_post_route?
        return unless @request.post?

        case @request.path
        when %r{^/admin/admin_terms}
          true
        end
      end

      def valid_in_get_context?(constraints)
        additional_constraints = []
        if @request.get?
          constraints.each do |constraint|
            next unless constraint.settings["participatory_space_manifest"].present? && constraint.settings.size > 1

            additional_constraints << OpenStruct.new(settings: {
                                                       "participatory_space_manifest" => constraint.settings["participatory_space_manifest"],
                                                       "match" => "exclusive"
                                                     })
          end
        end

        @config.valid_in_context?(constraints + additional_constraints)
      end
    end
  end
end
