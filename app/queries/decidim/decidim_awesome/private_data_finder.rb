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

      # Spaces in the trash are left out: Decidim freezes their contents until restored
      def components
        Decidim.participatory_space_manifests.map do |manifest|
          spaces = manifest.participatory_spaces.call(organization)
          Component.with_deleted.where(participatory_space_type: manifest.model_class_name, participatory_space_id: spaces.select(:id))
        end.reduce(:or)
      end

      private

      attr_reader :organization

      def proposals
        Decidim::Proposals::Proposal.with_deleted
                                    .select(:decidim_component_id)
                                    .where(decidim_component_id: components.select(:id))
      end

      def extra_fields
        ProposalExtraField.with_deleted.where(decidim_proposal_type: Decidim::Proposals::Proposal.name)
      end
    end
  end
end
