# frozen_string_literal: true

class AddDecidimAwesomeProposalPrivateFields < ActiveRecord::Migration[6.0]
  def change
    add_column :decidim_awesome_proposal_extra_fields, :private_body, :string
  end
end
