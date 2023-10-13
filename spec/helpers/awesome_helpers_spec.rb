# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe AwesomeHelpers, type: :helper do
    let!(:organization) { create :organization }
    let!(:another_organization) { create :organization }
    let(:component) { create :proposal_component, organization: organization, settings: { awesome_voting_manifest: manifest } }
    let(:manifest) { :three_flags }
    let(:request) { double(env: env, url: "/") }
    let(:env) do
      {
        "decidim.current_organization" => organization
      }
    end

    before do
      allow(helper).to receive(:request).and_return(request)
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
  end
end
