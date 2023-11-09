# frozen_string_literal: true

class CreateDecidimAwesomeProposalExtraFields < ActiveRecord::Migration[6.0]
  def change
    create_table :decidim_awesome_proposal_extra_fields do |t|
      # this might be polymorphic in the future (if other types of votes are supported)
      t.references :decidim_proposal, null: false, index: { name: "decidim_awesome_extra_fields_on_proposal" }

      t.jsonb :vote_weight_totals
      t.integer :weight_total, default: 0
      t.timestamps
    end
  end
end
