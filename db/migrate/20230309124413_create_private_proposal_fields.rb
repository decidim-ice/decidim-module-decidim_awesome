# frozen_string_literal: true

class CreatePrivateProposalFields < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_awesome_private_proposal_fields do |t|
      t.text :private_body, default: '<xml></xml>'

      t.references :proposal, null: false, foreign_key: { to_table: :decidim_proposals_proposals }, index: { name: "decidim_awesome_private_proposal_fields_idx" }
      t.timestamps
    end
  end
end
