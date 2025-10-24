# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module ProposalGCellOverride
      extend ActiveSupport::Concern
      include Decidim::DecidimAwesome::AwesomeHelpers

      included do
        private

        alias_method :decidim_original_cache_hash, :cache_hash

        def proposal_vote_cell
          @proposal_vote_cell ||= awesome_voting_manifest_for(resource&.component)&.proposal_vote_cell.presence || "decidim/proposals/proposal_vote"
        end

        def cache_hash
          @decidim_awesome_cache_hash ||= begin
            all_extra_fields = memoize("extra_fields")
            extra_fields = all_extra_fields ? all_extra_fields[resource.id] : resource.extra_fields
            "#{decidim_original_cache_hash}#{Decidim.cache_key_separator}#{extra_fields&.vote_weight_totals}"
          end
        end
      end
    end
  end
end
