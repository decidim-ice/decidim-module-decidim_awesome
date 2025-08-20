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
  end
end
