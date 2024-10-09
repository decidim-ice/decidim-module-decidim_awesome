# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module UseUserTimeZone
      extend ActiveSupport::Concern

      included do
        around_action :use_user_time_zone, if: -> { user_time_zone.present? }
        helper_method :user_time_zone

        # Executes a block of code in the context of the user's time zone
        #
        # &action - a block of code to be wrapped around the time zone
        #
        # Returns nothing.
        def use_user_time_zone(&)
          Time.use_zone(user_time_zone, &)
        end

        # The current time zone from the user. Available as a helper for the views.
        #
        # Returns a String.
        def user_time_zone
          @user_time_zone ||= current_user&.extended_data&.[]("time_zone")
        end
      end
    end
  end
end
