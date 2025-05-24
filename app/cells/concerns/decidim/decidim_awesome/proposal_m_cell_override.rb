# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module ProposalMCellOverride
      extend ActiveSupport::Concern

      included do
        alias_method :decidim_original_cache_hash, :cache_hash

        def cache_hash
          all_extra_fields = memoize("extra_fields")
          extra_fields = all_extra_fields ? all_extra_fields[model.id] : model.extra_fields

          @cache_hash ||= "#{decidim_original_cache_hash}#{Decidim.cache_key_separator}#{extra_fields&.vote_weight_totals}"
        end
      end
    end
  end
end
