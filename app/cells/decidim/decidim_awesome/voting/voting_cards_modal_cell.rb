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
          organization_name = translated_attribute(current_organization.name)
          instructions = translated_attribute(current_component.settings.voting_cards_instructions).presence
          return t("decidim.decidim_awesome.voting.voting_cards.default_instructions_html", organization: organization_name) unless instructions

          instructions.gsub("%{organization}", organization_name)
        end
      end
    end
  end
end
