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
        request = Rack::Request.new(env)
        if request.env["decidim.current_organization"]
          env["decidim_awesome.current_config"] = awesome_config_instance(request)
          tamper_user_model(env["decidim_awesome.current_config"])
        end

        @app.call(env)
      end

      private

      def awesome_config_instance(request)
        @awesome_config_instance = Config.new request.env["decidim.current_organization"]
        @awesome_config_instance.context_from_request request
        @awesome_config_instance
      end

      def tamper_user_model(config)
        Decidim::User.awesome_admins_for_current_scope = config.collect_sub_configs("scoped_admin").flatten.uniq.map(&:to_i)
      end
    end
  end
end
