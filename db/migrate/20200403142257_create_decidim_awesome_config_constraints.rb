# frozen_string_literal: true

class CreateDecidimAwesomeConfigConstraints < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_awesome_config_constraints do |t|
      t.jsonb :settings

      t.references :decidim_awesome_config, null: false, foreign_key: { to_table: :decidim_awesome_config }, index: { name: "decidim_awesome_config_constraints_config" }
      t.timestamps
    end
  end
end
