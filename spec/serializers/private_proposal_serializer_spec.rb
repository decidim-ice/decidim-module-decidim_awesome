# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome::Proposals
  describe PrivateProposalSerializer do
    subject do
      described_class.new(proposal)
    end

    let!(:proposal) { create(:proposal, :accepted, body:, component:) }
    let!(:another_proposal) { create(:proposal, :accepted, component:) }
    let!(:extra_fields) { create(:awesome_proposal_extra_fields, proposal:, private_body:) }
    let!(:another_extra_fields) { create(:awesome_proposal_extra_fields, proposal: another_proposal) }
    let(:component) { create(:proposal_component) }
    let(:participatory_process) { component.participatory_space }
    let(:organization) { participatory_process.organization }
    let(:custom_fields) do
      {
        foo: "[{\"type\":\"text\",\"required\":false,\"label\":\"Name\",\"name\":\"name\",\"subtype\":\"text\"}]"
      }
    end
    let(:private_custom_fields) do
      {
        bar: "[{\"type\":\"number\",\"required\":false,\"label\":\"Age\",\"name\":\"age\",\"subtype\":\"number\"}]"
      }
    end
    let!(:config) { create(:awesome_config, organization:, var: :proposal_custom_fields, value: custom_fields) }
    let!(:constraint) { create(:config_constraint, awesome_config: config, settings: { "participatory_space_manifest" => "participatory_processes", "participatory_space_slug" => slug }) }
    let!(:private_config) { create(:awesome_config, organization:, var: :proposal_private_custom_fields, value: private_custom_fields) }
    let!(:private_constraint) { create(:config_constraint, awesome_config: private_config, settings: { "participatory_space_manifest" => "participatory_processes", "participatory_space_slug" => private_slug }) }
    let!(:notes) { create_list(:proposal_note, 2, proposal:, created_at: "2024-01-01") }

    let(:slug) { participatory_process.slug }
    let(:private_slug) { participatory_process.slug }
    let(:body) { "<xml><dl><dt name=\"name\">Name</dt><dd id=\"name\" name=\"name\"><div>John Barleycorn</div></dd></dl></xml>" }
    let(:private_body) { "<xml><dl><dt name=\"age\">Age</dt><dd id=\"age\" name=\"number\"><div>12</div></dd></dl></xml>" }
    let(:all_notes) do
      notes.to_h do |note|
        [
          :"notes/#{note.id}",
          {
            created_at: note.created_at,
            note: note.body,
            author: note.author.name
          }
        ]
      end
    end

    describe "#serialize" do
      let(:serialized) { subject.serialize }

      it "serializes the id" do
        expect(serialized).to include(id: proposal.id)
      end

      it "serializes private notes" do
        expect(serialized).to include(all_notes)
      end

      it "serializes public and private custom fields in columns" do
        expect(serialized).to include("body/name/en": "John Barleycorn")
        expect(serialized).to include("private_body/age": "12")
      end

      context "when public fields not in scope" do
        let(:slug) { "another-slug" }

        it "serializes private fields only" do
          expect(serialized).to include("private_body/age": "12")
          expect(serialized.keys).not_to include("body/name/en")
        end
      end

      context "when private fields not in scope" do
        let(:private_slug) { "another-slug" }

        it "serializes public fields only" do
          expect(serialized.keys).not_to include("private_body/age/en")
          expect(serialized).to include("body/name/en": "John Barleycorn")
        end
      end
    end
  end
end
