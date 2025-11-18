# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Voting
      class VotingCardsModalCell < Decidim::ViewModel
        def show
          return if current_component&.settings&.voting_cards_show_modal_help == false

          render
        end

        def vote_instructions
          instructions = translated_attribute(current_component.settings.voting_cards_instructions).presence ||
                         t("decidim.decidim_awesome.voting.voting_cards.default_instructions_html", organization: translated_attribute(current_organization.name))

          format(instructions, organization: translated_attribute(current_organization.name))
        end
      end
    end
  end
end
