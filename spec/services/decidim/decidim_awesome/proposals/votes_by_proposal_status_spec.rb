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
        let(:proposal) { create(:proposal, component:, state: "accepted") }

        let(:settings_class) { Struct.new(:votes_enabled, :awesome_votes_enabled_by_status, :awesome_votes_enabled_states) }
        let(:settings) { settings_class.new(true, true, %w(accepted)) }

        describe "#active?" do
          context "when the global feature flag is disabled" do
            before { allow(Decidim::DecidimAwesome).to receive(:enabled?).with(:votes_by_proposal_status).and_return(false) }

            it { is_expected.not_to be_active }
          end

          context "when votes are not enabled on the step" do
            let(:settings) { settings_class.new(false, true, %w(accepted)) }

            it { is_expected.not_to be_active }
          end

          context "when the per-step checkbox is off" do
            let(:settings) { settings_class.new(true, false, %w(accepted)) }

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

          context "when only not_answered is selected" do
            let(:settings) { settings_class.new(true, true, %w(not_answered)) }

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
            let(:settings) { settings_class.new(true, true, %w(rejected)) }

            it { expect(subject.allowed?(proposal)).to be(false) }
          end

          context "when the proposal has no assigned status" do
            let(:proposal) { create(:proposal, component:) }

            context "and not_answered is in the allowed list" do
              let(:settings) { settings_class.new(true, true, %w(not_answered)) }

              it { expect(subject.allowed?(proposal)).to be(true) }
            end

            context "and not_answered is not in the allowed list" do
              it { expect(subject.allowed?(proposal)).to be(false) }
            end
          end

          context "when not_answered is mixed with real tokens" do
            let(:settings) { settings_class.new(true, true, %w(accepted not_answered)) }
            let(:not_answered_proposal) { create(:proposal, component:) }
            let(:rejected_proposal) { create(:proposal, component:, state: "rejected") }

            it "allows the answered proposal in the list" do
              expect(subject.allowed?(proposal)).to be(true)
            end

            it "allows the not-answered proposal" do
              expect(subject.allowed?(not_answered_proposal)).to be(true)
            end

            it "still blocks proposals whose status is not in the list" do
              expect(subject.allowed?(rejected_proposal)).to be(false)
            end
          end

          context "when the proposal is nil" do
            it { expect(subject.allowed?(nil)).to be(false) }
          end

          context "when the allowed list mixes blank entries and valid tokens" do
            let(:settings) { settings_class.new(true, true, ["", "accepted"]) }

            it { expect(subject.allowed?(proposal)).to be(true) }
          end
        end

        describe "#allowed_tokens" do
          context "with several tokens" do
            let(:settings) { settings_class.new(true, true, %w(accepted rejected not_answered)) }

            it { expect(subject.allowed_tokens).to eq(%w(accepted rejected not_answered)) }
          end

          context "with blank entries" do
            let(:settings) { settings_class.new(true, true, ["", " ", "accepted", nil]) }

            it { expect(subject.allowed_tokens).to eq(%w(accepted)) }
          end

          context "when the attribute is missing" do
            let(:settings) { Object.new }

            it { expect(subject.allowed_tokens).to eq([]) }
          end
        end

        describe ".choices_for" do
          subject { described_class.choices_for(component) }

          it "places not_answered first" do
            expect(subject.first).to eq([I18n.t("decidim.proposals.answers.not_answered"), "not_answered"])
          end

          it "lists the real component states with their tokens" do
            tokens = subject.map(&:last)
            expect(tokens).to include("accepted", "evaluating", "rejected")
          end
        end
      end
    end
  end
end
