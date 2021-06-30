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
          tamper_user_model(env)
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

      def tamper_user_model(env)
        return unless Decidim::User.respond_to? :awesome_admins_for_current_scope

        Decidim::User.awesome_potential_admins = potential_admins

        Decidim::User.awesome_admins_for_current_scope = if safe_get_route? || safe_post_route?
                                                           Decidim::User.awesome_potential_admins
                                                         else
                                                           valid_admins(env)
                                                         end
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

      # avoid unnecessary processing for non-user routes
      def processable_path?
        case @request.path
        when %r{^/api|^/oauth|^/system|^/assets}
          false
        when %r{^/delayed_job|^/sidekiq}
          false
        else
          true
        end
      end

      def safe_get_route?
        return unless @request.get?

        case @request.path
        when "/admin/"
          true
        when %r{^/admin/admin_terms}
          true
        when %r{^(?!(/*)admin/)} # not starting with "/admin/"
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
        constraints = [] if constraints.blank?

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
