# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # This class adds some attributes to the proposal model in a different table
    # in particular, it adds a private_body field that should be encrypted
    # However this field does not work with machine translations as are defined in the current TranslatableResource class
    # That's because, as the way it is implemented now, it skips callbacks and validations and updates the field directly in the database
    # (using update_column), efectively bypassing the encryption of the field.
    # On the other hand, encryption is not ready either to handle nested hashes, required for machine translations
    # So, for the moment, private_body won't be automatically translated
    class ProposalExtraField < ApplicationRecord
      include Decidim::RecordEncryptor

      self.table_name = "decidim_awesome_proposal_extra_fields"

      belongs_to :proposal, foreign_key: "decidim_proposal_id", class_name: "Decidim::Proposals::Proposal"

      encrypt_attribute :private_body, type: :hash

      # validate not more than one extra field can be associated to a proposal
      validates :proposal, uniqueness: true
    end
  end
end
