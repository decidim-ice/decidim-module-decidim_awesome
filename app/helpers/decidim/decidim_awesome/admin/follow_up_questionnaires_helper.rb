# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      module FollowUpQuestionnairesHelper
        include Decidim::TranslatableAttributes

        def grouped_questionnaire_options(questionnaires)
          finder = FollowUpQuestionnairesFinder.new(current_organization)

          questionnaires.group_by { |questionnaire| translated_attribute(finder.component_for(questionnaire).participatory_space.title) }
                        .transform_values { |list| list.map { |q| [translated_attribute(q.title), q.id] } }
                        .to_a
        end

        def questionnaires_questions_data(questionnaires)
          questionnaires.each_with_object({}) do |questionnaire, hash|
            hash[questionnaire.id] = questionnaire.questions.map { |q| [translated_attribute(q.body), q.id] }
          end
        end
      end
    end
  end
end
