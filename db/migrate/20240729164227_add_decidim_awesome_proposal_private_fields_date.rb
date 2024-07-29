# frozen_string_literal: true

class AddDecidimAwesomeProposalPrivateFieldsDate < ActiveRecord::Migration[6.1]
  class ProposalExtraField < ApplicationRecord
    self.table_name = :decidim_awesome_proposal_extra_fields
  end

  def change
    add_column :decidim_awesome_proposal_extra_fields, :private_body_updated_at, :datetime

    reversible do |direction|
      direction.up do
        execute <<~SQL.squish
          UPDATE decidim_awesome_proposal_extra_fields
          SET private_body_updated_at = updated_at
        SQL
      end
    end
  end
end
