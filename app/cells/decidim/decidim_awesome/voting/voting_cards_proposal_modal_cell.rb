# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Voting
      class VotingCardsProposalModalCell < VotingCardsBaseCell
        include Decidim::Proposals::Engine.routes.url_helpers

        def show
          render :show
        end

        def vote_instructions
          translated_attribute(current_component.settings.voting_cards_instructions).presence || t("decidim.decidim_awesome.voting.voting_cards.default_instructions_html",
                                                                                                   organization: current_organization.name)
        end
      end
    end
  end
end
