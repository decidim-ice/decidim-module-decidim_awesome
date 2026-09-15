# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CreateFollowUpQuestionnaireStatus < Decidim::Commands::CreateResource
        fetch_form_attributes :name, :color, :follow_up_questionnaire_id

        private

        def resource_class = Decidim::DecidimAwesome::FollowUpQuestionnaireStatus

        def extra_params
          questionnaire = Decidim::DecidimAwesome::FollowUpQuestionnaire.find(form.follow_up_questionnaire_id)
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
