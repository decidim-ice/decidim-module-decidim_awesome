# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module AccountFormOverride
      extend ActiveSupport::Concern

      included do
        attribute :user_time_zone
        validates :user_time_zone, time_zone: true, if: -> { user_time_zone.present? }

        def user_time_zone
          return nil if awesome_config[:user_timezone].blank?

          super.presence || current_user.extended_data["time_zone"].presence || current_organization.time_zone
        end

        # Used for the user_time_zone setting, which does not have constraints
        def awesome_config
          @awesome_config ||= Decidim::DecidimAwesome::Config.new(current_organization)&.organization_config || {}
        end
      end
    end
  end
end
