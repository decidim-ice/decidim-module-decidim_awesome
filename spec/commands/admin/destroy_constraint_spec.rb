# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe DestroyConstraint do
      subject { described_class.new(constraint) }

      let(:organization) { create(:organization) }
      # let(:context) do
      #   {
      #     current_user: create(:user, organization: organization),
      #     current_organization: organization,
      #     setting: config
      #   }
      # end
      let(:name) { :some_config_var }
      let(:config) { create(:awesome_config, organization:, var: name) }
      let!(:constraint) { create(:config_constraint, awesome_config: config, settings: { "test" => 1 }) }

      shared_examples "destroys the constraint" do
        it "broadcasts :ok and modifies the config options" do
          expect { subject.call }.to broadcast(:ok)

          expect(AwesomeConfig.find_by(organization:, var: config.var).constraints).not_to include(constraint)
        end
      end

      shared_examples "do not destroy the constraint" do
        it "broadcasts :invalid and does not modify the config options" do
          expect { subject.call }.to broadcast(:invalid)

          expect(AwesomeConfig.find_by(organization:, var: config.var).constraints).to include(constraint)
        end
      end

      context "when is not the last constraint" do
        let!(:constraint2) { create(:config_constraint, awesome_config: config, settings: { "test2" => 2 }) }

        context "and is a non-critical scope" do
          it_behaves_like "destroys the constraint"
        end

        context "and is a critical scope" do
          let(:name) { :proposal_custom_field }

          it_behaves_like "destroys the constraint"
        end
      end

      context "when is the last constraint" do
        context "and is a non-critical scope" do
          it_behaves_like "destroys the constraint"
        end

        context "and is a critical scope" do
          let(:name) { :proposal_custom_field }

          it_behaves_like "do not destroy the constraint"
        end
      end
    end
  end
end
