# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # Finds the components holding proposal private data, scoped to a single
    # organization
    class PrivateDataFinder
      def initialize(organization)
        @organization = organization
      end

      def query
        Component.with_deleted.where(id: proposals.where(id: extra_fields.where.not(private_body: nil).select(:decidim_proposal_id)))
      end

      def for(resources)
        Component.with_deleted.where(id: proposals.where(id: extra_fields.select(:decidim_proposal_id))).where(id: resources)
      end

      private

      attr_reader :organization

      def proposals
        Decidim::Proposals::Proposal.with_deleted
                                    .select(:decidim_component_id)
                                    .where(decidim_component_id: organization_components)
      end

      def extra_fields
        ProposalExtraField.with_deleted
      end

      def organization_components
        Component.with_deleted.where(participatory_space: organization.participatory_spaces).select(:id)
      end
    end
  end
end
