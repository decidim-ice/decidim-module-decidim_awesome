# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module NeedsHashcash
      extend ActiveSupport::Concern

      included do
        include AwesomeHelpers
        include ActiveHashcash

        helper_method :awesome_hashcash_bits
        before_action :set_hashcash_bits
        before_action :awesome_check_hashcash, only: :create # rubocop:disable Rails/LexicallyScopedActionFilter
      end

      private

      def awesome_hashcash_bits(zone)
        return false unless awesome_config[:"hashcash_#{zone}"]

        awesome_config[:"hashcash_#{zone}_bits"]
      end

      def awesome_check_hashcash
        return unless set_hashcash_bits

        check_hashcash
      end

      # Dynamically configures the gem https://github.com/BaseSecrete/active_hashcash
      def set_hashcash_bits
        return unless %w(registrations sessions).include?(controller_name)
        return if user_signed_in?

        ActiveHashcash.bits = if controller_name == "registrations"
                                awesome_hashcash_bits(:signup)
                              else
                                awesome_hashcash_bits(:login)
                              end
      end
    end
  end
end
