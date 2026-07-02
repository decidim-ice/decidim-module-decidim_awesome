# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module NeedsThreadVariables
      extend ActiveSupport::Concern

      included do
        before_action :set_thread_organization
        after_action :clear_thread_organization
      end

      private

      def set_thread_organization
        return unless respond_to?(:current_organization)

        config = Decidim::DecidimAwesome::AwesomeConfig.find_by(
          organization: current_organization,
          var: :awesome_authorization_handler
        )
        Thread.current[:awesome_authorization_handler] = config&.value
      end

      def clear_thread_organization
        Thread.current[:awesome_authorization_handler] = nil
      end
    end
  end
end
