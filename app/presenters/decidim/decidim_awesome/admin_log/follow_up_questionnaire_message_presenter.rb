# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module AdminLog
      class FollowUpQuestionnaireMessagePresenter < Decidim::Log::BasePresenter
        private

        # The message content and the respondent are not shown in the admin log
        def diff_fields_mapping = {}

        def action_string
          return super unless action == "create"
          return "decidim.decidim_awesome.admin_log.follow_up_questionnaire_message.create_as" if author_name.present?

          "decidim.decidim_awesome.admin_log.follow_up_questionnaire_message.create"
        end

        def i18n_params
          super.merge(
            questionnaire_name: action_log.extra.dig("resource", "follow_up_questionnaire_name"),
            author_name:
          )
        end

        def author_name
          action_log.extra.dig("resource", "author_name")
        end
      end
    end
  end
end
