# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class AwesomeAuthorizationHandler < Decidim::AuthorizationHandler
      validate :not_available_yet

      private

      def not_available_yet
        errors.add(:base, :invalid)
      end
    end
  end
end
