# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class PrivateDataFinder
      def query
        Component.where(
          id: Decidim::Proposals::Proposal.select(:decidim_component_id)
                                          .joins(:extra_fields)
                                          .where(extra_fields: { private_body: nil })
        )
      end
    end
  end
end
