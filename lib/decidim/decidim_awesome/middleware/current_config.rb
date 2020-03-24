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
        AwesomeConfig.where(organization: env["decidim.current_organization"]).all.map { |v| [v.var.to_sym, v.value] }.to_h
      end
    end
  end
end
