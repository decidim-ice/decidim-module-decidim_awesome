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
        Thread.current[:current_organization] = current_organization if respond_to?(:current_organization)
      end

      def clear_thread_organization
        Thread.current[:current_organization] = nil
      end
    end
  end
end
