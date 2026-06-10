# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DecidimAwesome
    module Voting
      describe VotingCardsProposalVoteCell, type: :cell do
        subject { cell("decidim/decidim_awesome/voting/voting_cards_proposal_vote", proposal, context: { current_user: user }) }

        let(:organization) { create(:organization) }
        let(:user) { create(:user, :confirmed, organization:) }
        let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
        let(:component) do
          create(
            :proposal_component,
            :with_votes_enabled,
            participatory_space: participatory_process,
            settings: { awesome_voting_manifest: "voting_cards" }
          )
        end
        let(:proposal) { create(:proposal, component:, state: "accepted") }

        describe "#show" do
          before do
            allow(subject).to receive(:awesome_voting_restricted_by_status?).with(proposal).and_return(restricted)
          end

          context "when voting is restricted by status" do
            let(:restricted) { true }

            it "renders the not_allowed template" do
              expect(subject).to receive(:render).with(:not_allowed)
              subject.show
            end
          end

          context "when voting is not restricted by status" do
            let(:restricted) { false }

            it "delegates to the original voting cards rendering" do
              expect(subject).not_to receive(:render).with(:not_allowed)
              expect { subject.show }.not_to raise_error
            end
          end
        end
      end
    end
  end
end
