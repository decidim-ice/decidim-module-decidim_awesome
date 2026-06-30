# frozen_string_literal: true

class CreateDecidimAwesomeAuthorizationUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :decidim_awesome_authorization_users do |t|
      t.string :email, null: false
      t.references :authorization_group, null: false, foreign_key: { to_table: :decidim_awesome_authorization_groups }, index: { name: "decidim_awesome_authorization_users_authorization_group_id" }

      t.timestamps
    end

    add_index :decidim_awesome_authorization_users, [:authorization_group_id, :email], name: "index_auth_users_group_email", unique: true
  end
end
