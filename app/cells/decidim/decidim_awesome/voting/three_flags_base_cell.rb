# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Voting
      class ThreeFlagsBaseCell < Decidim::ViewModel
        include Decidim::IconHelper
        include Decidim::ComponentPathHelper
        include Decidim::Proposals::Engine.routes.url_helpers
        def proposal
          model
        end

        def current_component
          proposal.component
        end

        def current_vote
          @current_vote ||= Decidim::Proposals::ProposalVote.find_by(author: current_user, proposal: model)
        end
      end
    end
  end
end
