# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe CreateConstraint do
      subject { described_class.new(form) }

      let(:organization) { create(:organization) }
      let(:context) do
        {
          current_user: create(:user, organization: organization),
          current_organization: organization,
          setting: config
        }
      end
      let(:config) { create :awesome_config, organization: organization }
      let(:params) do
        {
          "participatory_space_manifest" => "some-manifest"
        }
      end
      let(:form) do
        ConstraintForm.from_params(params).with_context(context)
      end

      describe "when valid" do
        before do
          allow(form).to receive(:valid?).and_return(true)
        end

        it "broadcasts :ok and modifies the config options" do
          expect { subject.call }.to broadcast(:ok)

          expect(AwesomeConfig.find_by(organization: organization, var: config.var).constraints.first.settings).to eq(params)
        end
      end

      describe "when invalid" do
        before do
          allow(form).to receive(:valid?).and_return(false)
        end

        let!(:config) do
          create(:awesome_config, organization: organization)
        end

        it "broadcasts :invalid and does not modifiy the config options" do
          expect { subject.call }.to broadcast(:invalid)

          expect(AwesomeConfig.find_by(organization: organization, var: config.var).constraints).to eq([])
        end
      end
    end
  end
end
