class AddProposalsPrivateBody < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_proposals_proposals, :private_body, :text, null: false, default: "<xml></xml>"
  end
end
