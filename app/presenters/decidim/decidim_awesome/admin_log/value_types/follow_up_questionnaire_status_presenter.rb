# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module AdminLog
      module ValueTypes
        class FollowUpQuestionnaireStatusPresenter < Decidim::Log::ValueTypes::DefaultPresenter
          def present
            return unless value

            color_entry = Decidim::DecidimAwesome.follow_up_status_colors.values.find { |v| v[:background] == value }
            color_entry&.dig(:name) || value
          end
        end
      end
    end
  end
end
