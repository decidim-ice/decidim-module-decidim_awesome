# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalVoteCell, type: :cell do
      subject { cell("decidim/proposals/proposal_vote", proposal, context: { current_user: user }) }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :confirmed, organization:) }
      let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
      let(:component) { create(:proposal_component, :with_votes_enabled, participatory_space: participatory_process) }
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

          it "delegates to the original show implementation" do
            expect(subject).to receive(:awesome_original_show)
            expect(subject).not_to receive(:render).with(:not_allowed)
            subject.show
          end
        end
      end
    end
  end
end
