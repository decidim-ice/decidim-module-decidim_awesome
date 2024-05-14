# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Voting
      class VotingCardsBaseCell < Decidim::ViewModel
        include Decidim::IconHelper
        include Decidim::ComponentPathHelper
        include Decidim::Proposals::ProposalVotesHelper
        include Decidim::Proposals::Engine.routes.url_helpers

        delegate :current_settings, to: :current_component

        def proposal
          model
        end

        def sanitized_title
          strip_tags(translated_attribute(proposal.title))
        end

        def current_component
          proposal.component
        end

        def component_settings
          current_component.settings
        end

        def current_vote
          @current_vote ||= Decidim::Proposals::ProposalVote.find_by(author: current_user, proposal: model)
        end

        def user_voted_weight
          current_vote&.weight
        end
      end
    end
  end
end
