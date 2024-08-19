# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module ProposalMCellOverride
      extend ActiveSupport::Concern

      included do
        alias_method :decidim_original_cache_hash, :cache_hash

        def cache_hash
          extra_hash = model.extra_fields&.reload&.vote_weight_totals
          "#{decidim_original_cache_hash}#{Decidim.cache_key_separator}#{extra_hash}"
        end
      end
    end
  end
end
