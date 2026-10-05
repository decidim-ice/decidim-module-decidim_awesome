# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class UpdateFollowUpQuestionnaire < Decidim::Commands::UpdateResource
        include Decidim::TranslatableAttributes

        protected

        # The linked survey cannot change once there are messages, like Decidim::Forms::Admin::UpdateQuestions
        def attributes
          return form.to_params.merge(component: form.component) if resource.questionnaire_editable?

          form.to_params.except(:decidim_questionnaire_id)
        end

        def extra_params
          { resource: { follow_up_questionnaire_name: translated_attribute(form.name) } }
        end
      end
    end
  end
end
