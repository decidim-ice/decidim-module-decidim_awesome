# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class FollowUpQuestionnairesFinder
        def initialize(organization, excluding: nil)
          @organization = organization
          @excluding = excluding
        end

        def query
          Decidim::Forms::Questionnaire.where.not(id: configured_ids).order(created_at: :desc).select do |questionnaire|
            component_for(questionnaire).present?
          end
        end

        def component_for(questionnaire)
          questionnaire_for = questionnaire.questionnaire_for
          component = questionnaire_for.respond_to?(:component) ? questionnaire_for.component : nil
          return nil if component&.participatory_space.blank?
          return nil unless component.organization == organization

          component
        end

        private

        attr_reader :organization, :excluding

        def configured_ids
          scope = Decidim::DecidimAwesome::FollowUpQuestionnaire.all
          scope = scope.where.not(id: excluding) if excluding
          scope.pluck(:decidim_questionnaire_id)
        end
      end
    end
  end
end
