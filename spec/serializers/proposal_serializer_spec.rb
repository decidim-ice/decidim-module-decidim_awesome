# frozen_string_literal: true

require "spec_helper"

module Decidim::Proposals
  describe ProposalSerializer do
    subject do
      described_class.new(proposal)
    end

    let!(:proposal) { create(:proposal, :accepted, component: component) }
    let!(:another_proposal) { create(:proposal, :accepted, component: component) }
    let!(:weight_cache) { create(:awesome_weight_cache, proposal: proposal) }
    let(:weights) do
      {
        "0" => 1,
        "3" => 2
      }
    end
    let!(:votes) do
      weights.each do |weight, count|
        count.times do
          vote = create(:proposal_vote, proposal: proposal, author: create(:user, organization: proposal.organization))
          create(:awesome_vote_weight, vote: vote, weight: weight)
        end
      end
    end
    let!(:another_weight_cache) { create(:awesome_weight_cache, :with_votes, proposal: another_proposal) }
    let(:participatory_process) { component.participatory_space }
    let(:component) { create :proposal_component, settings: settings }
    let(:settings) do
      {
        awesome_voting_manifest: manifest
      }
    end
    let(:labeled_weights) do
      {
        "Abstain" => 1,
        "Red" => 0,
        "Yellow" => 0,
        "Green" => 2,
        "weight_4" => 0,
        "weight_5" => 0
      }
    end
    let(:manifest) { :three_flags }

    let!(:proposals_component) { create(:component, manifest_name: "proposals", participatory_space: participatory_process) }

    describe "#serialize" do
      let(:serialized) { subject.serialize }

      it "serializes the id" do
        expect(serialized).to include(id: proposal.id)
      end

      it "serializes the amount of supports" do
        expect(serialized).to include(supports: proposal.proposal_votes_count)
      end

      it "serializes the weights" do
        expect(serialized).to include(weights: labeled_weights)
      end

      context "when no manifest" do
        let(:manifest) { nil }

        it "serializes the weights" do
          expect(serialized).to include(weights: { "0" => 1, "1" => 0, "2" => 0, "3" => 2, "4" => 0, "5" => 0 })
        end
      end

      context "when vote_cache is outdated" do
        let(:wrong_weights) do
          { "1" => 101, "2" => 102, "3" => 103, "4" => 104, "5" => 105 }
        end
        let(:labeled_wrong_weights) do
          { "Abstain" => 0, "Red" => 101, "Yellow" => 102, "Green" => 103, "weight_4" => 104, "weight_5" => 105 }
        end

        before do
          # rubocop:disable Rails/SkipsModelValidations:
          # we don't want to trigger the active record hooks
          weight_cache.update_columns(totals: wrong_weights)
          # rubocop:enable Rails/SkipsModelValidations:
        end

        it "serializes the weights" do
          expect(proposal.vote_weights).to eq(labeled_wrong_weights)
          expect(serialized).to include(weights: labeled_weights)
          weight_cache.reload
          expect(proposal.reload.vote_weights).to eq(labeled_weights)
        end
      end
    end
  end
end
