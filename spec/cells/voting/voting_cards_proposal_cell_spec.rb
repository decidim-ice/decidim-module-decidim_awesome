# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DecidimAwesome
    module Voting
      describe VotingCardsProposalCell, type: :cell do
        subject { cell("decidim/decidim_awesome/voting/voting_cards_proposal", proposal, context: { current_user: user }) }

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

        describe "#weight_count_for" do
          it "returns the correct number of votes for a given weight" do
            expect(subject.weight_count_for(1)).to eq(3)
            expect(subject.weight_count_for(2)).to eq(2)
            expect(subject.weight_count_for(3)).to eq(1)
          end
        end

        describe "#voted_for?" do
          context "when user has voted" do
            before do
              create(:awesome_vote_weight, vote: create(:proposal_vote, proposal: proposal, author: user), weight: 1)
            end

            it "returns true for the weight the user has voted for" do
              expect(subject.voted_for?(1)).to be(true)
            end

            it "returns false for the weights the user has not voted for" do
              expect(subject.voted_for?(2)).to be(false)
              expect(subject.voted_for?(3)).to be(false)
            end
          end
        end

        describe "#from_proposals_list" do
          it "returns the value passed in options" do
            cell_with_option = cell("decidim/decidim_awesome/voting/voting_cards_proposal", proposal, current_user: user, from_proposals_list: true)
            expect(cell_with_option.from_proposals_list).to be(true)

            cell_without_option = cell("decidim/decidim_awesome/voting/voting_cards_proposal", proposal, current_user: user)
            expect(cell_without_option.from_proposals_list).to be_nil
          end
        end
      end
    end
  end
end
