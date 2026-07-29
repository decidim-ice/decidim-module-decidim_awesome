# frozen_string_literal: true

class CreateFollowUpQuestionnaireStatuses < ActiveRecord::Migration[7.0]
  def change
    create_table :follow_up_questionnaire_statuses do |t|
      t.references :follow_up_questionnaire,
                   null: false,
                   foreign_key: true,
                   index: { name: "index_fuqs_on_follow_up_questionnaire_id" }

      t.string :name, null: false
      t.string :color, null: false
      t.timestamps
    end
  end
end
