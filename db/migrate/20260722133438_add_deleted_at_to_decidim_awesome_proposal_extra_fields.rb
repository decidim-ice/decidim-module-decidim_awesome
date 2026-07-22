# frozen_string_literal: true

class AddDeletedAtToDecidimAwesomeProposalExtraFields < ActiveRecord::Migration[8.1]
  def change
    add_column :decidim_awesome_proposal_extra_fields, :deleted_at, :datetime
    add_index :decidim_awesome_proposal_extra_fields, :deleted_at
  end
end
