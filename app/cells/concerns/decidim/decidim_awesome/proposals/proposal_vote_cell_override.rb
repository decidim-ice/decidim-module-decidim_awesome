# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Proposals
      module ProposalVoteCellOverride
        extend ActiveSupport::Concern

        included do
          alias_method :awesome_original_show, :show

          def show
            return render(:not_allowed) if awesome_voting_restricted_by_status?(resource)

            awesome_original_show
          end
        end
      end
    end
  end
end
