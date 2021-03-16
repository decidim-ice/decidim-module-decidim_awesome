# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module OverviewComponent
      # This cell renders the Medium (:m) overview card
      # for an given instance of a Component
      class SurveyCell < OverviewMCell
        def items
          Decidim::Surveys::Survey.where(component: model)
        end
      end
    end
  end
end
