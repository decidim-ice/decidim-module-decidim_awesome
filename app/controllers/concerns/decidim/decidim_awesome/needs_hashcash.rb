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
        return false unless awesome_config["hashcash_#{zone}".to_sym]

        awesome_config["hashcash_#{zone}_bits".to_sym]
      end

      def awesome_check_hashcash
        return unless set_hashcash_bits

        check_hashcash
      end

      # Dynamically configures the gem https://github.com/BaseSecrete/active_hashcash
      def set_hashcash_bits
        if controller_name == "sessions"
          ActiveHashcash.bits = awesome_hashcash_bits(:login)
        elsif controller_name == "registrations"
          ActiveHashcash.bits = awesome_hashcash_bits(:signup)
        end
      end
    end
  end
end
