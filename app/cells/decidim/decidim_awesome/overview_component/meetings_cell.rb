# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module OverviewComponent
      # This cell renders the Medium (:m) overview card
      # for an given instance of a Component
      class MeetingsCell < OverviewMCell
        def items
          Decidim::Meetings::Meeting.where(component: model)
        end
      end
    end
  end
end
