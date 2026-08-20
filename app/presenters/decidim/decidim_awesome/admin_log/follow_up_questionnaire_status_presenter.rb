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

        def i18n_labels_scope = "activemodel.attributes.follow_up_questionnaire_statuses"
      end
    end
  end
end
