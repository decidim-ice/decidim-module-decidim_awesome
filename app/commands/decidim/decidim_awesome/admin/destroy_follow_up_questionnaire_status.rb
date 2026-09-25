# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class DestroyFollowUpQuestionnaireStatus < Decidim::Commands::DestroyResource
        protected

        def extra_params
          questionnaire = resource.follow_up_questionnaire
          {
            resource: {
              follow_up_questionnaire_name: questionnaire.translated_attribute(questionnaire.name)
            }
          }
        end
      end
    end
  end
end
