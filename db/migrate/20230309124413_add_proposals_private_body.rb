class AddProposalsPrivateBody < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_proposals_proposals, :private_body, :text, null: false
  end
end
