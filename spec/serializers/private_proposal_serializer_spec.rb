# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome::Proposals
  describe PrivateProposalSerializer do
    subject do
      described_class.new(proposal)
    end

    let!(:proposal) { create(:proposal, :accepted, component:) }
    let!(:another_proposal) { create(:proposal, :accepted, component:) }
    let!(:extra_fields) { create(:awesome_proposal_extra_fields, proposal:, private_body:) }
    let!(:another_extra_fields) { create(:awesome_proposal_extra_fields, proposal: another_proposal) }
    let(:participatory_process) { component.participatory_space }
    let(:component) { create(:proposal_component) }
    let(:custom_fields) do
      {
        foo: "[{\"type\":\"number\",\"required\":false,\"label\":\"Age\",\"name\":\"age\",\"subtype\":\"number\"}]"
      }
    end
    let!(:config) { create(:awesome_config, organization: participatory_process.organization, var: :proposal_private_custom_fields, value: custom_fields) }
    let!(:constraint) { create(:config_constraint, awesome_config: config, settings: { "participatory_space_manifest" => "participatory_processes", "participatory_space_slug" => slug }) }
    let(:slug) { participatory_process.slug }

    let(:private_body) { "<xml><dl class=\"decidim_awesome-custom_fields\" data-generator=\"decidim_awesome\" data-version=\"0.11.0\">\n<dt name=\"age\">Age</dt>\n<dd id=\"age\" name=\"number\"><div>12</div></dd>\n</dl></xml>" }

    describe "#serialize" do
      let(:serialized) { subject.serialize }

      it "serializes the id" do
        expect(serialized).to include(id: proposal.id)
      end

      it "serializes private custom fields in private_body/:name/:locale column" do
        expect(serialized).to include("private_body/age": "12")
      end

      context "when not in scope" do
        let(:slug) { "another-slug" }

        it "does not serialize custom fields" do
          expect(serialized).not_to include("private_body/age/en")
        end
      end
    end
  end
end
