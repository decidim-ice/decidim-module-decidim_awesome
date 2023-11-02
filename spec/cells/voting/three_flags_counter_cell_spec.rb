# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DecidimAwesome
    module Voting
      describe ThreeFlagsCounterCell, type: :cell do
        subject { cell("decidim/decidim_awesome/voting/three_flags_counter", proposal, context: { current_user: user }) }

        let(:manifest) { :three_flags }
        let!(:organization) { create :organization }
        let(:user) { create(:user, :confirmed, organization: organization) }
        let!(:component) { create :proposal_component, :with_votes_enabled, organization: organization, settings: { awesome_voting_manifest: manifest } }
        let(:proposal) { create(:proposal, component: component) }
        let!(:weight_cache) { create(:awesome_weight_cache, proposal: proposal) }
        let!(:vote_weights) do
          [
            create_list(:awesome_vote_weight, 3, vote: create(:proposal_vote, proposal: proposal), weight: 1),
            create_list(:awesome_vote_weight, 2, vote: create(:proposal_vote, proposal: proposal), weight: 2),
            create_list(:awesome_vote_weight, 1, vote: create(:proposal_vote, proposal: proposal), weight: 3)
          ]
        end

        describe "#user_voted_weight" do
          context "when user has voted" do
            before do
              create(:awesome_vote_weight, vote: create(:proposal_vote, proposal: proposal, author: user), weight: 1)
            end

            it "returns the weight of the user's vote for the proposal" do
              expect(subject.user_voted_weight).to eq(1)
            end
          end

          context "when user has not voted" do
            it "returns nil" do
              expect(subject.user_voted_weight).to be_nil
            end
          end
        end

        describe "#vote_btn_class" do
          context "when user has voted with weight 1" do
            before do
              create(:awesome_vote_weight, vote: create(:proposal_vote, proposal: proposal, author: user), weight: 1)
            end

            it "returns 'danger'" do
              expect(subject.vote_btn_class).to eq("danger")
            end
          end

          context "when user has not voted" do
            it "returns 'hollow'" do
              expect(subject.vote_btn_class).to eq("hollow")
            end
          end
        end
      end
    end
  end
end
