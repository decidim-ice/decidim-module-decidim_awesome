# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module AdminLog
      class FollowUpQuestionnairePresenter < Decidim::Log::BasePresenter
        private

        def diff_fields_mapping
          {
            name: :i18n,
            position: :integer,
            active: :boolean,
            reply_to: :string
          }
        end

        def action_string
          case action
          when "create", "update", "delete"
            "decidim.decidim_awesome.admin_log.follow_up_questionnaire.#{action}"
          else
            super
          end
        end

        def i18n_params
          super.merge(questionnaire_name: action_log.extra.dig("resource", "follow_up_questionnaire_name"))
        end

        def i18n_labels_scope = "activemodel.attributes.follow_up_questionnaire"
      end
    end
  end
end
