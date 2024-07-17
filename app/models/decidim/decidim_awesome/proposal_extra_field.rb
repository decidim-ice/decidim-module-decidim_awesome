# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class ProposalExtraField < ApplicationRecord
      include ::Decidim::TranslatableResource
      include ::Decidim::TranslatableAttributes

      self.table_name = "decidim_awesome_proposal_extra_fields"

      translatable_fields :private_body
      belongs_to :proposal, foreign_key: "decidim_proposal_id", class_name: "Decidim::Proposals::Proposal"

      def private_body
        return nil if private_body_encrypted.nil?

        private_body_encrypted.transform_values do |encrypted_value|
          Decidim::AttributeEncryptor.decrypt(encrypted_value)
        end
      end

      def private_body=(clear_private_body)
        if clear_private_body.nil?
          self.private_body_encrypted = nil
          return
        end

        self.private_body_encrypted = clear_private_body.transform_values do |clear_value|
          Decidim::AttributeEncryptor.encrypt(clear_value)
        end
      end
    end
  end
end
