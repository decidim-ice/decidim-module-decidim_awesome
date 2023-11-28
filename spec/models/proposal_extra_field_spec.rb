# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe ProposalExtraField do
    subject { extra_fields }

    let(:extra_fields) { create(:awesome_proposal_extra_fields) }
    let(:proposal) { create(:proposal) }

    it { is_expected.to be_valid }

    it "has a proposal associated" do
      expect(extra_fields.proposal).to be_a(Decidim::Proposals::Proposal)
    end

    it "the associated proposal has a weight cache" do
      expect(extra_fields.proposal.extra_fields).to eq(extra_fields)
    end

    describe "weight_count" do
      let!(:extra_fields) { create(:awesome_proposal_extra_fields, proposal:) }
      let!(:vote_weights) do
        [
          create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 1),
          create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 2),
          create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 3)
        ]
      end

      it "returns the weight count for a weight" do
        expect(proposal.weight_count(1)).to eq(1)
        expect(proposal.weight_count(2)).to eq(1)
        expect(proposal.weight_count(3)).to eq(1)
      end

      context "when a vote is added" do
        before do
          create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 5)
          create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 3)
        end

        it "returns the weight count for a weight" do
          expect(proposal.weight_count(1)).to eq(1)
          expect(proposal.weight_count(2)).to eq(1)
          expect(proposal.weight_count(3)).to eq(2)
          expect(proposal.weight_count(4)).to eq(0)
          expect(proposal.weight_count(5)).to eq(1)
        end
      end

      context "when extra_fields does not exist" do
        let(:extra_fields) { nil }
        let(:vote_weights) { nil }

        it "returns 0" do
          expect(proposal.weight_count(1)).to eq(0)
          expect(proposal.weight_count(2)).to eq(0)
          expect(proposal.weight_count(3)).to eq(0)
          expect(proposal.weight_count(100)).to eq(0)
        end

        context "when a vote is added" do
          before do
            create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 5)
            create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 3)
          end

          it "returns the weight count for a weight" do
            expect(proposal.weight_count(1)).to eq(0)
            expect(proposal.weight_count(2)).to eq(0)
            expect(proposal.weight_count(3)).to eq(1)
            expect(proposal.weight_count(4)).to eq(0)
            expect(proposal.weight_count(5)).to eq(1)
          end
        end
      end
    end

    context "when proposal is destroyed" do
      let!(:extra_fields) { create(:awesome_proposal_extra_fields, proposal:) }

      it "destroys the proposal weight" do
        expect { proposal.destroy }.to change(Decidim::DecidimAwesome::ProposalExtraField, :count).by(-1)
      end
    end

    context "when proposal weight is destroyed" do
      let!(:extra_fields) { create(:awesome_proposal_extra_fields, proposal:) }

      it "does not destroy the proposal" do
        expect { extra_fields.destroy }.not_to change(Decidim::Proposals::ProposalVote, :count)
      end
    end

    context "when vote weight is" do
      describe "created" do
        it "increments the weight cache" do
          expect { create(:proposal_vote, proposal:) }.to change { proposal.votes.count }.by(1)
          expect { create(:awesome_vote_weight, vote: proposal.votes.first, weight: 3) }.to change(Decidim::DecidimAwesome::ProposalExtraField, :count).by(1)
          expect(proposal.extra_fields.vote_weight_totals).to eq({ "3" => 1 })
          expect(proposal.extra_fields.weight_total).to eq(3)
        end

        context "when cache already exists" do
          let(:another_proposal) { create(:proposal, component: proposal.component) }
          let!(:extra_fields) { create(:awesome_proposal_extra_fields, :with_votes, proposal:) }
          let!(:another_extra_fields) { create(:awesome_proposal_extra_fields, :with_votes, proposal: another_proposal) }

          it "has weights and votes" do
            expect(extra_fields.reload.vote_weight_totals).to eq({ "1" => 1, "2" => 1, "3" => 1, "4" => 1, "5" => 1 })
            expect(extra_fields.weight_total).to eq(15)
          end

          it "increments the weight cache" do
            create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 1)
            create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 3)
            create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 3)
            expect(extra_fields.reload.vote_weight_totals).to eq({ "1" => 2, "2" => 1, "3" => 3, "4" => 1, "5" => 1 })
            expect(extra_fields.weight_total).to eq(22)
          end
        end

        context "when cache does not exist yet" do
          let(:extra_fields) { proposal.reload.extra_fields }

          it "has no weights and votes" do
            expect(extra_fields).to be_nil
          end

          it "increments the weight cache" do
            create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 1)
            create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 3)
            create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 3)
            expect(extra_fields.vote_weight_totals).to eq({ "1" => 1, "3" => 2 })
            expect(extra_fields.weight_total).to eq(7)
          end
        end
      end

      # this is an unlikely scenario where voting removes and creates new vote weights, just in case...
      describe "updated" do
        let!(:vote_weight1) { create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 1) }
        let!(:vote_weight2) { create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 2) }
        let(:extra_fields) { proposal.reload.extra_fields }

        it "increments the weight cache" do
          vote_weight1.weight = 3
          vote_weight1.save
          expect(extra_fields.vote_weight_totals).to eq({ "2" => 1, "3" => 1 })
          expect(extra_fields.weight_total).to eq(5)
        end

        it "decreases the weight cache" do
          vote_weight2.weight = 1
          vote_weight2.save
          expect(extra_fields.vote_weight_totals).to eq({ "1" => 2 })
          expect(extra_fields.weight_total).to eq(2)
        end
      end

      describe "destroyed" do
        let!(:vote_weight1) { create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 1) }
        let!(:vote_weight2) { create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 2) }
        let(:extra_fields) { proposal.reload.extra_fields }

        it "decreases the weight cache" do
          vote_weight1.destroy
          expect(extra_fields.vote_weight_totals).to eq({ "2" => 1 })
          expect(extra_fields.weight_total).to eq(2)
        end
      end
    end

    describe "all_vote_weights" do
      let!(:extra_fields) { create(:awesome_proposal_extra_fields, proposal:) }
      let!(:another_extra_fields) { create(:awesome_proposal_extra_fields, proposal: another_proposal) }
      let!(:unrelated_another_extra_fields) { create(:awesome_proposal_extra_fields, :with_votes) }
      let(:another_proposal) { create(:proposal, component: proposal.component) }
      let!(:votes) do
        vote = create(:proposal_vote, proposal:, author: create(:user, organization: proposal.organization))
        create(:awesome_vote_weight, vote:, weight: 1)
      end
      let!(:other_votes) do
        vote = create(:proposal_vote, proposal: another_proposal, author: create(:user, organization: proposal.organization))
        create(:awesome_vote_weight, vote:, weight: 2)
      end

      it "returns all vote weights for a component" do
        expect(proposal.all_vote_weights).to contain_exactly(1, 2)
        expect(another_proposal.all_vote_weights).to contain_exactly(1, 2)
        expect(proposal.vote_weights).to eq({ "1" => 1, "2" => 0 })
        expect(another_proposal.vote_weights).to eq({ "1" => 0, "2" => 1 })
      end

      context "when wrong cache exists" do
        before do
          # rubocop:disable Rails/SkipsModelValidations:
          # we don't want to trigger the active record hooks
          extra_fields.update_columns(vote_weight_totals: { "3" => 1, "4" => 1 })
          # rubocop:enable Rails/SkipsModelValidations:
        end

        it "returns all vote weights for a component" do
          expect(proposal.extra_fields.vote_weight_totals).to eq({ "3" => 1, "4" => 1 })
          expect(proposal.vote_weights).to eq({ "1" => 0, "2" => 0 })
          proposal.update_vote_weights!
          expect(proposal.vote_weights).to eq({ "1" => 1, "2" => 0 })
          expect(another_proposal.vote_weights).to eq({ "1" => 0, "2" => 1 })
          expect(proposal.extra_fields.vote_weight_totals).to eq({ "1" => 1 })
          expect(another_proposal.extra_fields.vote_weight_totals).to eq({ "2" => 1 })
        end
      end
    end
  end
end
