# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DecidimAwesome
    describe PrivateDataFinder do
      subject { described_class.new(organization) }

      let(:organization) { create(:organization) }
      let(:other_organization) { create(:organization) }

      let(:component) { create(:proposal_component, organization:) }
      let(:other_component) { create(:proposal_component, organization: other_organization) }

      let(:proposal) { create(:proposal, component:) }
      let(:other_proposal) { create(:proposal, component: other_component) }

      let!(:extra_fields) { create(:awesome_proposal_extra_fields, proposal:, private_body: "secret A") }
      let!(:other_extra_fields) { create(:awesome_proposal_extra_fields, proposal: other_proposal, private_body: "secret B") }

      describe "#query" do
        it "returns components with private data from its own organization" do
          expect(subject.query).to include(component)
        end

        it "does not return components from other organizations" do
          expect(subject.query).not_to include(other_component)
        end
      end

      describe "#for" do
        it "does not return a component from another organization even when requested by id" do
          expect(subject.for([other_component.id])).not_to include(other_component)
        end

        it "still returns a requested component after its private data was cleared" do
          extra_fields.update(private_body: nil)
          expect(subject.for([component.id])).to include(component)
        end
      end

      context "when the component holding private data is trashed" do
        before { component.destroy }

        it "still finds it so its private data can be cleaned" do
          expect(subject.query).to include(component)
        end
      end

      context "when the proposal holding private data is trashed" do
        before { proposal.destroy }

        it "still finds its component so the private data can be cleaned" do
          expect(subject.query).to include(component)
        end

        it "still returns its component from #for" do
          expect(subject.for([component.id])).to include(component)
        end
      end

      context "when the participatory space holding private data is trashed" do
        before { component.participatory_space.destroy }

        it "leaves its components out until the space is restored" do
          expect(subject.query).not_to include(component)
          expect(subject.for([component.id])).not_to include(component)
        end
      end

      context "when an extra field row of another resource type shares the proposal id" do
        let!(:extra_fields) { create(:awesome_proposal_extra_fields, proposal:, private_body: nil) }

        before do
          ProposalExtraField.new(decidim_proposal_id: proposal.id, decidim_proposal_type: "Decidim::Proposals::CollaborativeDraft", private_body: "ghost")
                            .save(validate: false)
        end

        it "does not match the proposal" do
          expect(subject.query).not_to include(component)
        end
      end
    end
  end
end
