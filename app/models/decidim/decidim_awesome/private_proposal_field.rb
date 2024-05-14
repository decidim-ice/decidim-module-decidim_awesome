# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class PrivateProposalField < ApplicationRecord
      self.table_name = "decidim_awesome_private_proposal_fields"

      belongs_to :proposal,
                 inverse_of: :awesome_private_proposal_field,
                 class_name: "Decidim::Proposals::Proposal"
    end
  end
end
