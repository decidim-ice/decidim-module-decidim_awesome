# frozen_string_literal: true

# Default statuses used to be created lazily on the first admin request, so some
# follow-up questionnaires may still have none. Messages require a status.
class CreateDefaultFollowUpQuestionnaireStatuses < ActiveRecord::Migration[7.0]
  def up
    Decidim::DecidimAwesome::FollowUpQuestionnaire.reset_column_information
    Decidim::DecidimAwesome::FollowUpQuestionnaireStatus.reset_column_information

    with_statuses = Decidim::DecidimAwesome::FollowUpQuestionnaireStatus.select(:follow_up_questionnaire_id)
    Decidim::DecidimAwesome::FollowUpQuestionnaire.where.not(id: with_statuses).find_each do |follow_up_questionnaire|
      Decidim::DecidimAwesome.create_default_statuses!(follow_up_questionnaire)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
