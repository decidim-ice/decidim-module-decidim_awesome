# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe Permissions do
      subject { described_class.new(user, permission_action, context).permissions.allowed? }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :confirmed, organization:) }
      let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
      let(:component) { create(:proposal_component, participatory_space: participatory_process) }
      let(:accepted_state) { Decidim::Proposals::ProposalState.find_by(component:, token: "accepted") }
      let(:rejected_state) { Decidim::Proposals::ProposalState.find_by(component:, token: "rejected") }
      let(:proposal) { create(:proposal, component:, state: "accepted") }
      let(:current_settings) { component.current_settings }
      let(:component_settings) { component.settings }
      let(:context) { { current_component: component, current_settings:, component_settings:, proposal: } }
      let(:permission_action) { Decidim::PermissionAction.new(scope: :public, action:, subject: :proposal) }
      let(:action) { :vote }

      let(:step_settings) do
        { votes_enabled: true, awesome_votes_enabled_by_status: true, awesome_votes_enabled_states: }
      end
      let(:awesome_votes_enabled_states) { [accepted_state.id.to_s] }

      before do
        component.update!(step_settings: { participatory_process.active_step.id => step_settings })
      end

      shared_examples "blocks the action" do
        it { is_expected.to be(false) }
      end

      shared_examples "allows the action" do
        it { is_expected.to be(true) }
      end

      context "when the action is :vote" do
        let(:action) { :vote }

        context "when the proposal status is in the allowed list" do
          it_behaves_like "allows the action"
        end

        context "when the proposal status is not in the allowed list" do
          let(:awesome_votes_enabled_states) { [rejected_state.id.to_s] }

          it_behaves_like "blocks the action"
        end

        context "when the proposal has no assigned status" do
          let(:proposal) { create(:proposal, component:) }

          it_behaves_like "blocks the action"
        end

        context "when the awesome filter is disabled in the component" do
          let(:step_settings) { { votes_enabled: true, awesome_votes_enabled_by_status: false } }

          it_behaves_like "allows the action"
        end

        context "when the allowed list is empty" do
          let(:awesome_votes_enabled_states) { [] }

          it_behaves_like "allows the action"
        end
      end

      context "when the action is :unvote" do
        let(:action) { :unvote }

        context "when the proposal status is in the allowed list" do
          it_behaves_like "allows the action"
        end

        context "when the proposal status is not in the allowed list" do
          let(:awesome_votes_enabled_states) { [rejected_state.id.to_s] }

          it_behaves_like "blocks the action"
        end
      end
    end
  end
end
