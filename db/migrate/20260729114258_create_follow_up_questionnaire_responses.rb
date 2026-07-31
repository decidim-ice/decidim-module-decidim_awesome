# frozen_string_literal: true

class CreateFollowUpQuestionnaireResponses < ActiveRecord::Migration[7.0]
  def change
    create_table :decidim_awesome_follow_up_questionnaire_responses do |t|
      t.references :follow_up_questionnaire,
                   null: false,
                   foreign_key: { to_table: :decidim_awesome_follow_up_questionnaires },
                   index: { name: "index_fuqr_on_follow_up_questionnaire_id" }

      t.bigint :questionnaire_response_id, null: false
      t.references :status,
                   null: false,
                   foreign_key: { to_table: :decidim_awesome_follow_up_questionnaire_statuses },
                   index: { name: "index_fuqr_on_status_id" }
      t.text :body
      t.references :author,
                   polymorphic: true,
                   null: false,
                   index: { name: "index_fuqr_on_author" }

      t.timestamps
    end

    add_index :decidim_awesome_follow_up_questionnaire_responses,
              [:follow_up_questionnaire_id, :questionnaire_response_id, :created_at],
              name: "index_fuqr_on_questionnaire_response_created_at"
  end
end
