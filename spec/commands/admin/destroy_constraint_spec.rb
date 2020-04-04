# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe DestroyConstraint do
      subject { described_class.new(constraint) }

      let(:organization) { create(:organization) }
      let(:context) do
        {
          current_user: create(:user, organization: organization),
          current_organization: organization,
          setting: config
        }
      end
      let(:config) { create :awesome_config, organization: organization }
      let!(:constraint) { create(:config_constraint, awesome_config: config, settings: { "test" => 1 }) }

      describe "when valid" do
        it "broadcasts :ok and modifies the config options" do
          expect { subject.call }.to broadcast(:ok)

          expect(AwesomeConfig.find_by(organization: organization, var: config.var).constraints).to eq([])
        end
      end
    end
  end
end
