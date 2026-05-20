# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Proposals
      module PermissionsOverride
        extend ActiveSupport::Concern

        included do
          alias_method :awesome_original_can_vote_proposal?, :can_vote_proposal?
          alias_method :awesome_original_can_unvote_proposal?, :can_unvote_proposal?

          def can_vote_proposal?
            return awesome_original_can_vote_proposal? unless awesome_status_filter_active?
            return toggle_allow(false) unless awesome_proposal_status_allowed?

            awesome_original_can_vote_proposal?
          end

          def can_unvote_proposal?
            return awesome_original_can_unvote_proposal? unless awesome_status_filter_active?
            return toggle_allow(false) unless awesome_proposal_status_allowed?

            awesome_original_can_unvote_proposal?
          end

          private

          def awesome_status_filter_active?
            return @awesome_status_filter_active if defined?(@awesome_status_filter_active)

            @awesome_status_filter_active = awesome_votes_by_proposal_status.active?
          end

          def awesome_proposal_status_allowed?
            return @awesome_proposal_status_allowed if defined?(@awesome_proposal_status_allowed)

            @awesome_proposal_status_allowed = awesome_votes_by_proposal_status.allowed?(proposal)
          end

          def awesome_votes_by_proposal_status
            @awesome_votes_by_proposal_status ||= Decidim::DecidimAwesome::Proposals::VotesByProposalStatus.new(current_settings)
          end
        end
      end
    end
  end
end
