# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Proposals
      # "Votes by proposal status" filter logic, shared by Permissions and view helpers.
      class VotesByProposalStatus
        def initialize(settings)
          @settings = settings
        end

        def active?
          return false unless Decidim::DecidimAwesome.enabled?(:votes_by_proposal_status)
          return false unless @settings.try(:votes_enabled)
          return false unless @settings.try(:awesome_votes_enabled_by_status)

          allowed_tokens.any?
        end

        def allowed?(proposal)
          return false unless proposal

          allowed_tokens.include?(proposal.internal_state)
        end

        def allowed_tokens
          @allowed_tokens ||= Array(@settings.try(:awesome_votes_enabled_states)).compact_blank.map(&:to_s)
        end

        # [label, token] pairs for the admin multiselect: synthetic "not_answered" first, then real states.
        def self.choices_for(component)
          not_answered = [I18n.t("decidim.proposals.answers.not_answered"), "not_answered"]
          real_states = Decidim::Proposals::ProposalState
                        .where(component:)
                        .where.not(token: "not_answered")
                        .map { |state| [state.translated_attribute(state.title), state.token] }
          [not_answered] + real_states
        end
      end
    end
  end
end
