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
        Component.with_deleted.where(id: proposals.where.not(extra_fields: { private_body: nil }))
      end

      def for(resources)
        Component.with_deleted.where(id: proposals).where(id: resources)
      end

      private

      attr_reader :organization

      def proposals
        Decidim::Proposals::Proposal
          .select(:decidim_component_id)
          .joins(:extra_fields)
          .where(decidim_component_id: organization_components)
      end

      def organization_components
        Component.with_deleted.where(participatory_space: organization.participatory_spaces).select(:id)
      end
    end
  end
end
