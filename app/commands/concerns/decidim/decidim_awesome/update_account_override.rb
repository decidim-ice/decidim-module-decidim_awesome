# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module UpdateAccountOverride
      extend ActiveSupport::Concern

      included do
        alias_method :decidim_update_personal_data, :update_personal_data
        alias_method :decidim_send_update_summary!, :send_update_summary!

        def update_personal_data
          decidim_update_personal_data
          return if @form.user_time_zone.blank?

          current_user.extended_data ||= {}
          if @form.user_time_zone == current_organization.time_zone
            current_user.extended_data.delete("time_zone")
          else
            current_user.extended_data["time_zone"] = @form.user_time_zone
          end
        end

        def send_update_summary!(changes)
          decidim_send_update_summary!(changes - ["extended_data"])
        end
      end
    end
  end
end
