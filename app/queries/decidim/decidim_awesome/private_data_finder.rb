# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class PrivateDataFinder
      def query
        Component.where(id: proposals.where.not(extra_fields: { private_body: nil }))
      end

      def proposals
        Decidim::Proposals::Proposal.select(:decidim_component_id).joins(:extra_fields)
      end

      def for(resources)
        Component.where(id: proposals).where(id: resources)
      end
    end
  end
end
