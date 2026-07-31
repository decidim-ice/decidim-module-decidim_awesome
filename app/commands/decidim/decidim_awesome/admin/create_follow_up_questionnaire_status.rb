# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CreateFollowUpQuestionnaireStatus < Decidim::Commands::CreateResource
        fetch_form_attributes :name, :color, :follow_up_questionnaire_id

        private

        def resource_class = Decidim::DecidimAwesome::FollowUpQuestionnaireStatus
      end
    end
  end
end
