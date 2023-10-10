# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe VoteWeight do
    subject { vote_weight }

    let(:vote_weight) { create(:awesome_vote_weight) }

    it { is_expected.to be_valid }

    it "has a vote associated" do
      expect(vote_weight.vote).to be_a(Decidim::Proposals::ProposalVote)
    end

    it "the associated proposal vote has a vote weight" do
      expect(vote_weight.vote.vote_weight).to eq(vote_weight)
    end

    context "when vote is destroyed" do
      let(:vote) { create(:proposal_vote) }
      let!(:vote_weight) { create(:awesome_vote_weight, vote: vote) }

      it "destroys the vote weight" do
        expect { vote.destroy }.to change(Decidim::DecidimAwesome::VoteWeight, :count).by(-1)
      end
    end

    context "when vote weight is destroyed" do
      let(:vote) { create(:proposal_vote) }
      let!(:vote_weight) { create(:awesome_vote_weight, vote: vote) }

      it "does not destroy the vote" do
        expect { vote_weight.destroy }.not_to change(Decidim::Proposals::ProposalVote, :count)
      end
    end
  end
end
