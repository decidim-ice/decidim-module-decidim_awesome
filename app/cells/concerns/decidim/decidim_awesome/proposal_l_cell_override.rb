# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module ProposalLCellOverride
      extend ActiveSupport::Concern

      included do
        private

        alias_method :decidim_original_cache_hash, :cache_hash

        def metadata_cell
          awesome_voting_manifest_for(resource&.component)&.proposal_metadata_cell.presence || "decidim/proposals/proposal_metadata"
        end

        def cache_hash
          extra_hash = model.extra_fields&.reload&.vote_weight_totals
          "#{decidim_original_cache_hash}#{Decidim.cache_key_separator}#{extra_hash}"
        end
      end
    end
  end
end
