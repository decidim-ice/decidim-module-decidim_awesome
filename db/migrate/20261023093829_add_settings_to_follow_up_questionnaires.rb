# frozen_string_literal: true

class AddSettingsToFollowUpQuestionnaires < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_awesome_follow_up_questionnaires, :settings, :jsonb, null: false, default: {}
  end
end
