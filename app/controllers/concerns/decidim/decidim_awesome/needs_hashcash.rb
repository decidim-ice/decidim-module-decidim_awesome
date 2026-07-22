# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module NeedsHashcash
      extend ActiveSupport::Concern

      included do
        include AwesomeHelpers
        include ActiveHashcash

        helper_method :awesome_hashcash_bits
        # On page load: set the difficulty so the browser can compute the mark.
        before_action :set_hashcash_bits
        # On submit: verify the mark first, before anything can log the visitor in.
        prepend_before_action :awesome_check_hashcash, if: -> { action_name == "create" }
      end

      private

      # Difficulty configured for the login/signup form (false when disabled).
      def awesome_hashcash_bits(zone)
        return false unless awesome_config[:"hashcash_#{zone}"]

        awesome_config[:"hashcash_#{zone}_bits"]
      end

      # Rejects the submission when the proof-of-work mark is missing or invalid.
      def awesome_check_hashcash
        return unless %w(registrations sessions).include?(controller_name)

        bits = hashcash_bits_without_user(hashcash_zone)
        return unless bits

        ActiveHashcash.bits = bits
        check_hashcash
      end

      # Dynamically configures the gem https://github.com/BaseSecrete/active_hashcash
      def hashcash_zone
        controller_name == "registrations" ? :signup : :login
      end

      # Reads the setting directly: awesome_config would call current_user and
      # log the visitor in before the mark is checked.
      def hashcash_bits_without_user(zone)
        organization = request.env["decidim.current_organization"]
        return false unless organization

        config = Config.new(organization)
        config.context_from_request!(request)
        values = config.config
        return false unless values[:"hashcash_#{zone}"]

        values[:"hashcash_#{zone}_bits"]
      end

      # Sets the difficulty used to render the hidden field (skipped once logged in).
      def set_hashcash_bits
        return unless %w(registrations sessions).include?(controller_name)
        return if user_signed_in?

        ActiveHashcash.bits = awesome_hashcash_bits(hashcash_zone)
      end
    end
  end
end
