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
        private_body_encrypted.entries.map do |key, encrypted_value|
          [key, Decidim::AttributeEncryptor.decrypt(encrypted_value)]
        end.to_h
      end
      
      def private_body=(clear_private_body)
        return private_body_encrypted = nil if clear_private_body.nil?
        self.private_body_encrypted = clear_private_body.entries.map do |key, clear_value|
          [key, Decidim::AttributeEncryptor.encrypt(clear_value)]
        end.to_h
      end
    end
  end
end
