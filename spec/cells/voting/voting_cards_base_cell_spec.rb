# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DecidimAwesome
    module Voting
      describe VotingCardsBaseCell, type: :cell do
        subject { cell("decidim/decidim_awesome/voting/voting_cards_base", proposal, context: { current_user: user, controller: controller }) }

        let(:manifest) { :voting_cards }
        let!(:organization) { create :organization }
        let(:user) { create(:user, :confirmed, organization: organization) }
        let!(:component) { create :proposal_component, :with_votes_enabled, organization: organization, settings: { awesome_voting_manifest: manifest } }
        let(:proposal) { create(:proposal, component: component) }
        let!(:extra_fields) { create(:awesome_proposal_extra_fields, proposal: proposal) }
        let!(:vote_weights) do
          [
            create_list(:awesome_vote_weight, 3, vote: create(:proposal_vote, proposal: proposal), weight: 1),
            create_list(:awesome_vote_weight, 2, vote: create(:proposal_vote, proposal: proposal), weight: 2),
            create_list(:awesome_vote_weight, 1, vote: create(:proposal_vote, proposal: proposal), weight: 3)
          ]
        end
        let(:controller) { double("controller", request: request) }
        let(:request) { double("request", env: { "decidim.current_organization" => organization }) }

        describe "#proposal" do
          it "returns the model" do
            expect(subject.proposal).to eq(proposal)
          end
        end

        describe "#current_component" do
          it "returns the component of the proposal" do
            expect(subject.current_component).to eq(component)
          end
        end

        describe "#current_vote" do
          context "when user has voted" do
            before do
              create(:awesome_vote_weight, vote: create(:proposal_vote, proposal: proposal, author: user), weight: 1)
            end

            it "returns the current vote of the user for the proposal" do
              expect(subject.current_vote).to be_present
            end
          end

          context "when user has not voted" do
            it "returns nil" do
              expect(subject.current_vote).to be_nil
            end
          end
        end
      end
    end
  end
end
