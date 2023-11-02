# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim::Proposals
  describe ProposalType, type: :graphql do
    include_context "with a graphql class type"
    let(:component) { create(:proposal_component) }
    let!(:weight_cache) { create(:awesome_weight_cache, :with_votes, proposal: model) }
    let(:model) { create :proposal, component: component }

    describe "id" do
      let(:query) { "{ id }" }

      it "returns the proposal's id" do
        expect(response["id"]).to eq(model.id.to_s)
      end
    end

    describe "voteCount/voteWeights" do
      let(:query) { "{ voteCount voteWeights }" }

      context "when votes are not hidden" do
        it "returns the amount of votes for this proposal" do
          expect(response["voteCount"]).to eq(5)
        end

        it "returns the weights of votes for this proposal" do
          expect(response["voteWeights"]).to eq({ "1" => 1, "2" => 1, "3" => 1, "4" => 1, "5" => 1 })
        end
      end

      context "when votes are hidden" do
        let(:component) { create(:proposal_component, :with_votes_hidden) }

        it "returns nil" do
          expect(response["voteCount"]).to be_nil
          expect(response["voteWeights"]).to be_nil
        end
      end
    end
  end
end
