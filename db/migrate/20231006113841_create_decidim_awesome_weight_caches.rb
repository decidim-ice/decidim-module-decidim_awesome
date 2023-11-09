# frozen_string_literal: true

class CreateDecidimAwesomeWeightCaches < ActiveRecord::Migration[6.0]
  def change
    create_table :decidim_awesome_proposal_extra_fields do |t|
      # this might be polymorphic in the future (if other types of votes are supported)
      t.references :decidim_proposal, null: false, index: { name: "decidim_awesome_proposals_weights_cache" }

      t.jsonb :vote_weights_totals
      t.integer :weight_total, default: 0
      t.timestamps
    end
  end
end
