# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module NeedsThreadVariables
      extend ActiveSupport::Concern

      included do
        around_action :with_thread_variables
      end

      private

      def with_thread_variables
        set_thread_variables
        yield
      ensure
        clear_thread_variables
      end

      def set_thread_variables
        return unless respond_to?(:current_organization)

        config = Decidim::DecidimAwesome::AwesomeConfig.find_by(
          organization: current_organization,
          var: :awesome_authorization_handler
        )
        Thread.current[:awesome_authorization_handler] = config&.value
      end

      def clear_thread_variables
        Thread.current[:awesome_authorization_handler] = nil
      end
    end
  end
end
