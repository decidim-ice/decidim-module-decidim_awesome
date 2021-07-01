# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe AwesomeHelpers, type: :helper do
    let!(:organization) { create :organization }
    let!(:another_organization) { create :organization }
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
  end
end
