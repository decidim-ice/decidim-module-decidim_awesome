# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Voting
      class ThreeFlagsProposalModalCell < ThreeFlagsBaseCell
        include Decidim::Proposals::Engine.routes.url_helpers

        def show
          render :show
        end

        def vote_instructions
          translated_attribute(current_component.settings.three_flags_instructions).presence || t("decidim.decidim_awesome.voting.three_flags.default_instructions_html",
                                                                                                  organization: current_organization.name)
        end
      end
    end
  end
end
