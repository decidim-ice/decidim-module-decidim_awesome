# frozen_string_literal: true

require "spec_helper"

module Decidim::Proposals
  describe ProposalSerializer do
    subject do
      described_class.new(proposal)
    end

    let!(:proposal) { create(:proposal, :accepted, body: body, component: component) }
    let!(:another_proposal) { create(:proposal, :accepted, component: component) }
    let!(:extra_fields) { create(:awesome_proposal_extra_fields, proposal: proposal) }
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
    let!(:another_extra_fields) { create(:awesome_proposal_extra_fields, :with_votes, proposal: another_proposal) }
    let(:participatory_process) { component.participatory_space }
    let(:component) { create(:proposal_component, settings: settings) }
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
    let(:manifest) { :voting_cards }
    let(:xml) { "<xml><dl><dt name=\"name\">Name</dt><dd id=\"name\" name=\"name\"><div>John Barleycorn</div></dd><dt name=\"age\">Age</dt><dd id=\"age\" name=\"age\"><div>12</div></dd></dl></xml>" }
    let(:body) do
      {
        "en" => xml,
        "machine_translations" => {
          "ca" => xml.gsub("John Barleycorn", "Joan Ordi")
        }
      }
    end

    describe "#serialize" do
      let(:serialized) { subject.serialize }

      it "serializes the id" do
        expect(serialized).to include(id: proposal.id)
      end

      it "serializes the amount of supports" do
        expect(serialized).to include(supports: proposal.proposal_votes_count)
      end

      it "serializes the weights" do
        expect(serialized).to include(votes: labeled_weights)
      end

      context "when no manifest" do
        let(:manifest) { nil }

        it "serializes the weights" do
          expect(serialized).to include(votes: { "0" => 1, "1" => 0, "2" => 0, "3" => 2, "4" => 0, "5" => 0 })
        end
      end

      context "when custom fields are defined" do
        let(:custom_fields) do
          {
            foo: "[{\"type\":\"text\",\"required\":true,\"label\":\"Name\",\"name\":\"name\",\"subtype\":\"text\"},{\"type\":\"number\",\"required\":false,\"label\":\"Age\",\"name\":\"age\",\"subtype\":\"number\"}]"
          }
        end
        let!(:config) { create(:awesome_config, organization: participatory_process.organization, var: :proposal_custom_fields, value: custom_fields) }
        let!(:constraint) { create(:config_constraint, awesome_config: config, settings: { "participatory_space_manifest" => "participatory_processes", "participatory_space_slug" => slug }) }
        let(:slug) { participatory_process.slug }

        it "serializes custom fields in columns" do
          expect(serialized).to include("body/age/en": "12")
          expect(serialized).to include("body/age/ca": "12")
          expect(serialized).to include("body/name/en": "John Barleycorn")
          expect(serialized).to include("body/name/ca": "Joan Ordi")
        end

        context "when not in scope" do
          let(:slug) { "another-slug" }

          it "does not serialize custom fields" do
            expect(serialized).not_to include("body/age/en")
            expect(serialized).not_to include("body/name/en")
            expect(serialized).not_to include("body/age/ca")
            expect(serialized).not_to include("body/name/ca")
          end
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
          # rubocop:disable Rails/SkipsModelValidations
          extra_fields.update_columns(vote_weight_totals: wrong_weights)
          # rubocop:enable Rails/SkipsModelValidations
        end

        it "serializes the weights" do
          expect(proposal.vote_weights).to eq(labeled_wrong_weights)
          expect(serialized).to include(votes: labeled_weights)
          extra_fields.reload
          expect(proposal.reload.vote_weights).to eq(labeled_weights)
        end
      end
    end
  end
end
