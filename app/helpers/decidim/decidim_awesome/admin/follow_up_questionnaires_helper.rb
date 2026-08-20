# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      module FollowUpQuestionnairesHelper
        include Decidim::TranslatableAttributes

        def grouped_questionnaire_options(questionnaires)
          finder = FollowUpQuestionnairesFinder.new(current_organization)

          questionnaires.group_by { |questionnaire| translated_attribute(finder.component_for(questionnaire).participatory_space.title) }
                        .transform_values { |list| list.map { |q| questionnaire_option(q) } }
                        .to_a
        end

        def questionnaire_option(questionnaire)
          label = translated_attribute(questionnaire.title)
          return [label, questionnaire.id] if questionnaire.questions.any?

          label = "#{label} (#{t("decidim.decidim_awesome.admin.follow_up_questionnaires.form.anonymous_option_flag")})"
          [label, questionnaire.id, { style: "background-color: #fef3c7; color: #92400e;" }]
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
