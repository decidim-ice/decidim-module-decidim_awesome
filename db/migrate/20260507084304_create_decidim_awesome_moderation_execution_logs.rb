# frozen_string_literal: true
class CreateDecidimAwesomeModerationExecutionLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :decidim_awesome_moderation_execution_logs do |t|
      t.references :decidim_organization, null: false, index: true
      t.references :resource, polymorphic: true, null: false
      t.string :rule_id
      t.string :rule_type
      t.string :action_id
      t.string :action_type
      t.boolean :matched, default: false, null: false
      t.boolean :applied, default: false, null: false
      t.string :status
      t.text :error_message
      t.string :timestamps

      t.timestamps
    end
  end
end
