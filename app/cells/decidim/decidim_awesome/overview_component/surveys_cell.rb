# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module OverviewComponent
      # This cell renders the Medium (:m) overview card
      # for an given instance of a Component
      class SurveysCell < OverviewMCell
        def items
          Decidim::Surveys::Survey.find_by(component: model).questionnaire.questions
        end

        def has_children?
          false
        end
      end
    end
  end
end
