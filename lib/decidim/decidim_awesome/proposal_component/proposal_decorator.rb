# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    ##
    # Add a relation to the private custom field, to be sure to
    # detroy relation if destroyed.
    module ProposalDecorator
      extend ActiveSupport::Concern
      included do |_base|
        has_one :awesome_private_proposal_field,
                class_name: "Decidim::DecidimAwesome::PrivateProposalField",
                foreign_key: "proposal_id",
                inverse_of: :proposal,
                dependent: :destroy
        accepts_nested_attributes_for :awesome_private_proposal_field

        ##
        # Attribute reader for proposal model.
        def private_body
          private_field = awesome_private_proposal_field || Decidim::DecidimAwesome::PrivateProposalField.new
          private_field.private_body
        end
      end
    end
  end
end
