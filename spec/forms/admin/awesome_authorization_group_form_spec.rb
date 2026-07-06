# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe AwesomeAuthorizationGroupForm do
      subject { described_class.from_params(attributes).with_context(current_organization: organization) }

      let(:organization) { create(:organization) }
      let(:name) do
        { "en" => "My Authorization Group" }
      end
      let(:purpose) do
        { "en" => "My Group Purpose" }
      end
      let(:attributes) do
        {
          name:,
          purpose:
        }
      end

      context "when all attributes are valid" do
        it { is_expected.to be_valid }
      end

      context "when name is blank" do
        let(:name) { { "en" => "" } }

        it { is_expected.not_to be_valid }
      end

      context "when name is missing" do
        let(:name) { {} }

        it { is_expected.not_to be_valid }
      end

      context "when purpose is blank" do
        let(:purpose) { { "en" => "" } }

        it { is_expected.not_to be_valid }
      end

      context "when purpose is missing" do
        let(:purpose) { {} }

        it { is_expected.not_to be_valid }
      end

      context "when both name and purpose are present in multiple locales" do
        let(:name) do
          { "en" => "My Authorization Group", "ca" => "El meu grup" }
        end
        let(:purpose) do
          { "en" => "My Group Purpose", "ca" => "El propòsit del meu grup" }
        end

        it { is_expected.to be_valid }
      end
    end
  end
end
