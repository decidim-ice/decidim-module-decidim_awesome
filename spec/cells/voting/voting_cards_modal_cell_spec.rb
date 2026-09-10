# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DecidimAwesome
    module Voting
      describe VotingCardsModalCell, type: :cell do
        subject { cell_instance.vote_instructions }

        let(:organization) { create(:organization, name: { en: "My Org" }) }
        let(:component) { create(:proposal_component, organization:, settings: { awesome_voting_manifest: :voting_cards, voting_cards_instructions: instructions }) }
        let(:proposal) { create(:proposal, component:) }
        let(:cell_instance) { cell("decidim/decidim_awesome/voting/voting_cards_modal", proposal) }

        before do
          allow(cell_instance).to receive(:current_component).and_return(component)
          allow(cell_instance).to receive(:current_organization).and_return(organization)
        end

        context "when the instructions contain a literal percent sign" do
          let(:instructions) { { en: "Distribute up to 20% of the budget" } }

          it "renders the instructions without raising" do
            expect { subject }.not_to raise_error
            expect(subject).to include("20%")
          end
        end

        context "when the instructions interpolate the organization name" do
          let(:instructions) { { en: "Welcome to %{organization}" } }

          it "still interpolates the organization" do
            expect(subject).to include("My Org")
          end
        end
      end
    end
  end
end
