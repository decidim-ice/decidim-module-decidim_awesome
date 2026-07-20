# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Proposals
      # Renders the votes count view defined by the active voting manifest
      # instead of the default one
      module ProposalVotesCountCellOverride
        def show
          view = awesome_voting_manifest_for(component)&.show_votes_count_view
          return super if view.nil?

          return render(partial: view, formats: [:html], locals: { proposal: resource, from_proposals_list: from_proposals_list? }) if view.present?

          awesome_hidden_votes_count_placeholder
        end

        private

        # Hidden placeholder kept in the DOM so update_buttons_and_counters.js.erb
        # can update the votes count without raising a console error.
        def awesome_hidden_votes_count_placeholder
          return if current_settings.votes_hidden?

          content_tag(:span, progress, style: "display: none", id: element_id)
        end
      end
    end
  end
end
