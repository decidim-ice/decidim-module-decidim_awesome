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
        if @request.env["decidim.current_organization"] && processable_path?
          @config = awesome_config_instance
          env["decidim_awesome.current_config"] = @config
          tamper_user_model
          add_flash_message_from_request(env)

          # puts "requested path: #{env["PATH_INFO"]}"
          # puts "current_organization: #{@request.env["decidim.current_organization"]&.id}"
          # puts "potential_admins: #{Decidim::User.awesome_potential_admins}"
          # puts "scoped admins: #{Decidim::User.awesome_admins_for_current_scope}"
        else
          reset_user_model
        end

        @app.call(env)
      end

      private

      # a workaround to set a flash message if comming from the error controller (route not found)
      def add_flash_message_from_request(env)
        return unless @request.params.has_key? "unauthorized"

        env["rack.session"]["flash"] = ActionDispatch::Flash::FlashHash.new(alert: I18n.t("decidim.core.actions.unauthorized")).to_session_value
      end

      def awesome_config_instance
        @awesome_config_instance = Config.new @request.env["decidim.current_organization"]
        @awesome_config_instance.context_from_request @request
        @awesome_config_instance
      end

      def reset_user_model
        Decidim::User.awesome_potential_admins = []
        Decidim::User.awesome_admins_for_current_scope = []
      end

      def tamper_user_model
        return unless Decidim::User.respond_to? :awesome_admins_for_current_scope

        Decidim::User.awesome_potential_admins = potential_admins

        Decidim::User.awesome_admins_for_current_scope = if safe_get_route? || safe_post_route?
                                                           Decidim::User.awesome_potential_admins
                                                         else
                                                           valid_admins
                                                         end
      end

      def potential_admins
        @config.collect_sub_configs_values("scoped_admin") do |subconfig|
          subconfig&.constraints&.detect { |c| c.settings["participatory_space_manifest"] == "none" } ? false : true
        end.flatten.uniq.map(&:to_i)
      end

      def valid_admins
        @config.collect_sub_configs_values("scoped_admin") do |subconfig|
          # allow index controllers if scoped to a subspace/component
          constraints = subconfig&.constraints || []
          additional_constraints = additional_get_constraints(constraints) + additional_post_constraints(constraints)
          # inject additional constraints here for further use
          @config.inject_sub_config_constraints("scoped_admin", subconfig.var[13..], additional_constraints)
          @config.valid_in_context?(constraints + additional_constraints)
        end.flatten.uniq.map(&:to_i)
      end

      # avoid unnecessary processing for non-user routes
      def processable_path?
        return true if safe_get_route?

        spaces = ContextAnalyzers::RequestAnalyzer.participatory_spaces_routes.keys.join("|^(/admin){0,1}/")
        case @request.path
        when %r{"|^(/admin){0,1}/#{spaces}}
          true
        when %r{^/admin/}
          true
        end
      end

      def safe_get_route?
        return unless @request.get?

        case @request.path
        when "/"
          true
        when "/admin/"
          true
        when %r{^/admin/admin_terms}
          true
        when %r{^/profiles/|^/notifications/|^/conversations/|^/pages/}
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

      # adds a exclusive constraint to the parent participatory space (so index page can be accessed)
      def additional_get_constraints(constraints)
        return [] unless @request.get?

        # ruby 2.7 required!
        constraints.filter_map do |constraint|
          next unless constraint.settings["participatory_space_manifest"].present? && constraint.settings.size > 1

          OpenStruct.new(settings: {
                           "participatory_space_manifest" => constraint.settings["participatory_space_manifest"],
                           "match" => "exclusive"
                         })
        end
      end

      # adds access to REST routes with id instead of the slug ot allow editing
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity:
      def additional_post_constraints(constraints)
        return [] unless @request.post? || @request.patch?

        constraints.filter_map do |constraint|
          settings = constraint.settings.dup
          next unless settings["participatory_space_manifest"].present? && settings["participatory_space_slug"].present?

          # replicate the constraint with the id of the participatory space
          manifest = Decidim.participatory_space_manifests.find { |s| s.name.to_s == settings["participatory_space_manifest"] }
          next unless manifest

          model = manifest.model_class_name.try(:constantize)
          next unless model

          settings["participatory_space_slug"] = model.find_by(slug: settings["participatory_space_slug"])&.id
          OpenStruct.new(settings: settings) if settings["participatory_space_slug"]
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/PerceivedComplexity:
    end
  end
end
