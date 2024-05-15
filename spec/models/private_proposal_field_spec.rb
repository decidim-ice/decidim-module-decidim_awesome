# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe PrivateProposalField do
    subject { private_proposal_field }

    let(:proposal) { create(:proposal) }
    let(:private_proposal_field) { create(:private_proposal_field, proposal: proposal) }

    it { is_expected.to be_valid }

    it "private_proposal_field is associated with proposal" do
      expect(subject).to eq(private_proposal_field)
      expect(subject.proposal).to eq(proposal)
    end

    it "is destroyed when the proposal is destroyed" do
      private_proposal_field.proposal.destroy
      expect(Decidim::DecidimAwesome::PrivateProposalField.find_by(id: private_proposal_field.id)).to be_nil
    end
  end
end
