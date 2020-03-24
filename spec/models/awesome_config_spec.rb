# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe AwesomeConfig do
    subject { awesome_config }

    let(:organization) { create(:organization) }
    let(:awesome_config) { create(:awesome_config, organization: organization) }

    it { is_expected.to be_valid }

    it "awesome_config is associated with organization" do
      expect(subject).to eq(awesome_config)
      expect(subject.organization).to eq(organization)
    end
  end
end
