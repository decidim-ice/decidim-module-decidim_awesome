# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DecidimAwesome
    module Proposals
      describe VotesByProposalStatus do
        subject { described_class.new(settings) }

        let(:organization) { create(:organization) }
        let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
        let(:component) { create(:proposal_component, participatory_space: participatory_process) }
        let(:accepted_state) { Decidim::Proposals::ProposalState.find_by(component:, token: "accepted") }
        let(:rejected_state) { Decidim::Proposals::ProposalState.find_by(component:, token: "rejected") }
        let(:proposal) { create(:proposal, component:, state: "accepted") }

        let(:settings_class) { Struct.new(:votes_enabled, :awesome_votes_enabled_by_status, :awesome_votes_enabled_states) }
        let(:settings) { settings_class.new(true, true, [accepted_state.id.to_s]) }

        describe "#active?" do
          context "when the global feature flag is disabled" do
            before { allow(Decidim::DecidimAwesome).to receive(:enabled?).with(:votes_by_proposal_status).and_return(false) }

            it { is_expected.not_to be_active }
          end

          context "when votes are not enabled on the step" do
            let(:settings) { settings_class.new(false, true, [accepted_state.id.to_s]) }

            it { is_expected.not_to be_active }
          end

          context "when the per-step checkbox is off" do
            let(:settings) { settings_class.new(true, false, [accepted_state.id.to_s]) }

            it { is_expected.not_to be_active }
          end

          context "when no states are selected" do
            let(:settings) { settings_class.new(true, true, []) }

            it { is_expected.not_to be_active }
          end

          context "when only blank states are selected" do
            let(:settings) { settings_class.new(true, true, ["", nil]) }

            it { is_expected.not_to be_active }
          end

          context "when the checkbox is on and at least one state is selected" do
            it { is_expected.to be_active }
          end

          context "when the settings object does not respond to the awesome attributes" do
            let(:settings) { Object.new }

            it { is_expected.not_to be_active }
          end
        end

        describe "#allowed?" do
          context "when the proposal status is in the allowed list" do
            it { expect(subject.allowed?(proposal)).to be(true) }
          end

          context "when the proposal status is not in the allowed list" do
            let(:settings) { settings_class.new(true, true, [rejected_state.id.to_s]) }

            it { expect(subject.allowed?(proposal)).to be(false) }
          end

          context "when the proposal has no assigned status" do
            let(:proposal) { create(:proposal, component:) }

            it { expect(subject.allowed?(proposal)).to be(false) }
          end

          context "when the proposal is nil" do
            it { expect(subject.allowed?(nil)).to be(false) }
          end

          context "when the allowed list mixes blank entries and valid ids" do
            let(:settings) { settings_class.new(true, true, ["", accepted_state.id.to_s]) }

            it { expect(subject.allowed?(proposal)).to be(true) }
          end
        end

        describe "#allowed_state_ids" do
          context "with string ids" do
            let(:settings) { settings_class.new(true, true, %w(1 2 3)) }

            it { expect(subject.allowed_state_ids).to eq([1, 2, 3]) }
          end

          context "with blank entries" do
            let(:settings) { settings_class.new(true, true, ["", " ", "5", nil]) }

            it { expect(subject.allowed_state_ids).to eq([5]) }
          end

          context "when the attribute is missing" do
            let(:settings) { Object.new }

            it { expect(subject.allowed_state_ids).to eq([]) }
          end
        end
      end
    end
  end
end
