# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class CurrentConfig
      def initialize(app)
        @app = app
      end

      def call(env)
        env["decidim_awesome.current_config"] = detect_current_config(env)
        @app.call(env)
      end

      private

      def detect_current_config(env)
        AwesomeConfig.config_for env["decidim.current_organization"]
      end
    end
  end
end
