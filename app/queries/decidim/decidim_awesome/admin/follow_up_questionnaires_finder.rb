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
          organization_questionnaires.where.not(id: configured_ids)
                                     .includes(:questions, questionnaire_for: { component: { participatory_space: :organization } })
                                     .order(created_at: :desc)
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

        def organization_questionnaires
          scopes = Decidim::Forms::Questionnaire.distinct.pluck(:questionnaire_for_type).filter_map do |type|
            owner_class = type.safe_constantize
            next unless owner_class&.include?(Decidim::HasComponent)

            Decidim::Forms::Questionnaire.where(
              questionnaire_for_type: type,
              questionnaire_for_id: owner_class.unscoped.where(decidim_component_id: organization_components.select(:id)).select(:id)
            )
          end
          scopes.reduce(:or) || Decidim::Forms::Questionnaire.none
        end

        def organization_components
          @organization_components ||= begin
            spaces = Decidim.participatory_space_manifests.flat_map do |manifest|
              manifest.participatory_spaces.call(organization)
            end
            Decidim::Component.unscope(:order).where(participatory_space: spaces)
          end
        end

        def configured_ids
          scope = Decidim::DecidimAwesome::FollowUpQuestionnaire.all
          scope = scope.where.not(id: excluding) if excluding
          scope.pluck(:decidim_questionnaire_id)
        end
      end
    end
  end
end
