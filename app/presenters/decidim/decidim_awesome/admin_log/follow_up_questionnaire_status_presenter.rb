# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module AdminLog
      class FollowUpQuestionnaireStatusPresenter < Decidim::Log::BasePresenter
        private

        def diff_fields_mapping
          {
            name: :i18n,
            color: "Decidim::DecidimAwesome::AdminLog::ValueTypes::FollowUpQuestionnaireStatusPresenter"
          }
        end

        def action_string
          case action
          when "create", "update", "delete"
            "decidim.decidim_awesome.admin_log.follow_up_questionnaire_status.#{action}"
          else
            super
          end
        end

        def i18n_params
          super.merge(
            label_name: resource_presenter.try(:present),
            questionnaire_name: action_log.extra.dig("resource", "follow_up_questionnaire_name")
          )
        end

        def i18n_labels_scope = "activemodel.attributes.follow_up_questionnaire_statuses"
      end
    end
  end
end
