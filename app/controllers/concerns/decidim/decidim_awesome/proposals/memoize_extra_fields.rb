# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Proposals
      module MemoizeExtraFields
        extend ActiveSupport::Concern
        include Decidim::DecidimAwesome::RequestMemoizer

        included do
          alias_method :decidim_original_index, :index

          def index
            decidim_original_index

            memoize("extra_fields") { Decidim::DecidimAwesome::ProposalExtraField.where(proposal: @proposals).index_by(&:decidim_proposal_id) }
            memoize("user_votes") { Decidim::Proposals::ProposalVote.where(proposal: proposals, author: current_user).index_by(&:decidim_proposal_id) if current_user }
          end
        end
      end
    end
  end
end
