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
      end
    end
  end
end
