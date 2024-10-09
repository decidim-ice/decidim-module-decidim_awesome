# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module AccountFormOverride
      extend ActiveSupport::Concern

      included do
        attribute :user_time_zone
        validates :user_time_zone, time_zone: true, if: -> { user_time_zone.present? }

        def user_time_zone
          super.presence || current_user.extended_data["time_zone"].presence || current_organization.time_zone
        end
      end
    end
  end
end
