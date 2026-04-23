# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe AwesomeHelpers do
    let!(:organization) { create(:organization, available_authorizations:) }
    let(:available_authorizations) { [] }
    let!(:another_organization) { create(:organization) }
    let(:component) { create(:proposal_component, organization:, settings: { awesome_voting_manifest: manifest }) }
    let(:another_component) { create(:proposal_component, manifest_name: :another_component, organization:, settings: { awesome_voting_manifest: manifest }) }
    let(:user) { create(:user, organization:) }
    let(:manifest) { :voting_cards }
    let(:request) { double(env:, url: "/") }
    let(:env) do
      {
        "decidim.current_organization" => organization
      }
    end
    let(:voting_components) { [:proposals, :another_component] }

    before do
      allow(helper).to receive(:request).and_return(request)
      allow(helper).to receive(:current_user).and_return(user)
      helper.instance_variable_set(:@awesome_config_instance, nil)
    end

    it "return a config instance" do
      config = helper.awesome_config_instance

      expect(helper.awesome_config_instance).to be_a(Config)
      expect(helper.awesome_config_instance).to eq(config)
      expect(helper.awesome_config_instance.organization).to eq(organization)
    end

    context "when there's a env config" do
      let(:env) do
        {
          "decidim.current_organization" => organization,
          "decidim_awesome.current_config" => Config.new(another_organization)
        }
      end

      it "reuses the same config" do
        expect(helper.awesome_config_instance).to be_a(Config)
        expect(helper.awesome_config_instance.organization).not_to eq(organization)
        expect(helper.awesome_config_instance.organization).to eq(another_organization)
      end
    end

    it "returns a voting manifest" do
      expect(helper.awesome_voting_manifest_for(component)).to be_a(VotingManifest)
      expect(helper.awesome_voting_manifest_for(component).name).to eq(manifest)
    end

    context "when no manifest" do
      let(:manifest) { nil }

      it "returns nil" do
        expect(helper.awesome_voting_manifest_for(component)).to be_nil
      end
    end

    context "when no voting components" do
      it "returns nil" do
        expect(helper.awesome_voting_manifest_for(another_component)).to be_nil
      end
    end

    it "returns authorizations for user" do
      expect(helper.awesome_authorizations_for(user)).to be_a(Decidim::DecidimAwesome::Authorizer)
      expect(helper.awesome_authorizations_for(user).authorizations).to eq([])
    end

    context "when organization has authorizations" do
      let(:available_authorizations) { [:dummy_authorization_handler] }

      it "returns the authorization" do
        expect(helper.awesome_authorizations_for(user).authorizations).to eq([
                                                                               {
                                                                                 name: "dummy_authorization_handler",
                                                                                 fullname: "Example authorization",
                                                                                 granted: nil,
                                                                                 pending: false,
                                                                                 managed: false
                                                                               }
                                                                             ])
      end

      context "when an authorization exists" do
        let!(:authorization) { create(:authorization, :granted, user:, name: "dummy_authorization_handler") }

        it "returns the authorization" do
          expect(helper.awesome_authorizations_for(user).authorizations).to eq([
                                                                                 {
                                                                                   name: "dummy_authorization_handler",
                                                                                   fullname: "Example authorization",
                                                                                   granted: true,
                                                                                   pending: false,
                                                                                   managed: false
                                                                                 }
                                                                               ])
        end
      end

      context "when the authorization is managed" do
        let!(:admins_available_authorizations) { create(:awesome_config, organization:, var: :admins_available_authorizations, value: [:dummy_authorization_handler]) }

        it "returns the authorization" do
          expect(helper.awesome_authorizations_for(user).authorizations).to eq([
                                                                                 {
                                                                                   name: "dummy_authorization_handler",
                                                                                   fullname: "Example authorization",
                                                                                   granted: nil,
                                                                                   pending: false,
                                                                                   managed: true
                                                                                 }
                                                                               ])
        end
      end
    end

    describe "#awesome_voting_restricted_by_status?" do
      subject { helper.awesome_voting_restricted_by_status?(proposal) }

      let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
      let(:filter_component) { create(:proposal_component, participatory_space: participatory_process) }
      let(:accepted_state) { Decidim::Proposals::ProposalState.find_by(component: filter_component, token: "accepted") }
      let(:rejected_state) { Decidim::Proposals::ProposalState.find_by(component: filter_component, token: "rejected") }
      let(:proposal) { create(:proposal, component: filter_component, state: "accepted") }

      let(:step_settings) { {} }

      before do
        filter_component.update!(step_settings: { participatory_process.active_step.id => step_settings })
      end

      context "when the global feature flag is disabled" do
        let(:step_settings) { { awesome_votes_enabled_by_status: true, awesome_votes_enabled_states: [rejected_state.id.to_s] } }

        before { allow(Decidim::DecidimAwesome).to receive(:votes_by_proposal_status).and_return(false) }

        it { is_expected.to be(false) }
      end

      context "when votes are blocked at the step level" do
        let(:step_settings) do
          { votes_blocked: true, awesome_votes_enabled_by_status: true, awesome_votes_enabled_states: [rejected_state.id.to_s] }
        end

        it { is_expected.to be(false) }
      end

      context "when the awesome filter is not enabled in the component" do
        let(:step_settings) { { awesome_votes_enabled_by_status: false } }

        it { is_expected.to be(false) }
      end

      context "when the filter is enabled but no statuses are selected" do
        let(:step_settings) { { awesome_votes_enabled_by_status: true, awesome_votes_enabled_states: [] } }

        it { is_expected.to be(false) }
      end

      context "when the filter is enabled and the proposal status is in the allowed list" do
        let(:step_settings) { { awesome_votes_enabled_by_status: true, awesome_votes_enabled_states: [accepted_state.id.to_s] } }

        it { is_expected.to be(false) }
      end

      context "when the filter is enabled and the proposal status is not in the allowed list" do
        let(:step_settings) { { awesome_votes_enabled_by_status: true, awesome_votes_enabled_states: [rejected_state.id.to_s] } }

        it { is_expected.to be(true) }
      end

      context "when the filter is enabled and the proposal has no assigned status" do
        let(:proposal) { create(:proposal, component: filter_component) }
        let(:step_settings) { { awesome_votes_enabled_by_status: true, awesome_votes_enabled_states: [accepted_state.id.to_s] } }

        it { is_expected.to be(true) }
      end

      context "when the allowed list contains blank entries" do
        let(:step_settings) do
          { awesome_votes_enabled_by_status: true, awesome_votes_enabled_states: ["", accepted_state.id.to_s] }
        end

        it { is_expected.to be(false) }
      end
    end
  end
end
