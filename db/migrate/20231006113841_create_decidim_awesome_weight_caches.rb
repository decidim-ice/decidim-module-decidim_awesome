# frozen_string_literal: true

class CreateDecidimAwesomeWeightCaches < ActiveRecord::Migration[6.0]
  def change
    create_table :decidim_awesome_weight_caches do |t|
      # this might be polymorphic in the future (if other types of votes are supported)
      t.references :decidim_proposal, null: false, index: { name: "decidim_awesome_proposals_weights_cache" }

      t.jsonb :totals
      t.integer :weight_total, default: 0
      t.timestamps
    end
  end
end
