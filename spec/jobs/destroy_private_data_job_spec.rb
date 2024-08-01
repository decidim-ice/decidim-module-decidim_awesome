# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe DestroyPrivateDataJob do
    subject { described_class }

    let!(:organization) { create(:organization) }
    let!(:user) { create(:user, organization:) }

    let!(:proposal) { create(:proposal, component:) }
    let!(:proposal2) { create(:proposal, component:) }
    let!(:modern_proposal) { create(:proposal, component:) }
    let!(:component) { create(:proposal_component, organization:) }
    let!(:extra_field) { create(:awesome_proposal_extra_fields, proposal:, private_body: "private") }
    let!(:extra_field2) { create(:awesome_proposal_extra_fields, proposal: proposal2, private_body: "private") }
    let!(:modern_extra_field) { create(:awesome_proposal_extra_fields, proposal: modern_proposal, private_body: "private") }

    let!(:another_component) { create(:proposal_component, organization:) }
    let!(:another_proposal) { create(:proposal, component: another_component) }
    let!(:another_extra_field) { create(:awesome_proposal_extra_fields, proposal: another_proposal, private_body: "private") }

    let!(:external_organization) { create(:organization) }
    let!(:external_component) { create(:proposal_component, organization: external_organization) }
    let!(:external_proposal) { create(:proposal, component: external_component) }
    let!(:external_extra_field) { create(:awesome_proposal_extra_fields, proposal: external_proposal, private_body: "private") }

    before do
      allow(::Decidim::DecidimAwesome).to receive(:private_data_expiration_time).and_return(3.months)
      # rubocop:disable Rails/SkipsModelValidations
      extra_field.update_column(:private_body_updated_at, 4.months.ago)
      extra_field2.update_column(:private_body_updated_at, 4.months.ago)
      modern_extra_field.update_column(:private_body_updated_at, 2.months.ago)
      another_extra_field.update_column(:private_body_updated_at, 4.months.ago)
      external_extra_field.update_column(:private_body_updated_at, 4.months.ago)
      # rubocop:enable Rails/SkipsModelValidations
    end

    it "cleans up the private data associated with the resource" do
      subject.perform_now(component)

      expect(ProposalExtraField.find(extra_field.id).private_body).to be_nil
      expect(ProposalExtraField.find(extra_field2.id).private_body).to be_nil
      expect(ProposalExtraField.find(modern_extra_field.id).private_body).to eq("private")
      expect(ProposalExtraField.find(another_extra_field.id).private_body).to eq("private")
      expect(ProposalExtraField.find(external_extra_field.id).private_body).to eq("private")
    end

    context "when there's a lock adquired" do
      before do
        Lock.new(organization).get!(component)
      end

      it "releases the lock" do
        expect(Lock.new(organization)).to be_locked(component)

        subject.perform_now(component)

        expect(ProposalExtraField.find(extra_field.id).private_body).to be_nil
        expect(ProposalExtraField.find(extra_field2.id).private_body).to be_nil
        expect(Lock.new(organization)).not_to be_locked(component)
      end
    end
  end
end
