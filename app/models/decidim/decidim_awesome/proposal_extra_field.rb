# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class ProposalExtraField < ApplicationRecord
      include ::Decidim::TranslatableResource
      include ::Decidim::TranslatableAttributes
      self.table_name = "decidim_awesome_proposal_extra_fields"
      translatable_fields :private_body

      belongs_to :proposal, foreign_key: "decidim_proposal_id", class_name: "Decidim::Proposals::Proposal"
    end
  end
end
