# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # This class adds some attributes to the proposal model in a different table
    # in particular, it adds a private_body field that should be encrypted
    # private_body is not translatable, nor is intended to be as it won't be shown to the public
    class ProposalExtraField < ApplicationRecord
      include Decidim::RecordEncryptor

      self.table_name = "decidim_awesome_proposal_extra_fields"

      belongs_to :proposal, foreign_key: "decidim_proposal_id", foreign_type: "decidim_proposal_type", polymorphic: true

      encrypt_attribute :private_body, type: :string

      # validate not more than one extra field can be associated to a proposal
      # validates :proposal, uniqueness: true
      validate :no_more_than_one_extra_field

      private

      def no_more_than_one_extra_field
        return unless ProposalExtraField.where(proposal:).where.not(id:).exists?

        errors.add(:proposal, :invalid)
      end
    end
  end
end
