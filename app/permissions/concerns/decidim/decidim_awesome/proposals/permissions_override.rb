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
            return false unless current_settings.respond_to?(:awesome_votes_enabled_by_status)
            return false unless current_settings.awesome_votes_enabled_by_status

            awesome_allowed_state_ids.any?
          end

          def awesome_proposal_status_allowed?
            return false unless proposal&.decidim_proposals_proposal_state_id

            awesome_allowed_state_ids.include?(proposal.decidim_proposals_proposal_state_id)
          end

          def awesome_allowed_state_ids
            Array(current_settings.awesome_votes_enabled_states).compact_blank.map(&:to_i)
          end
        end
      end
    end
  end
end
