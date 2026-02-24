# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe CookieItemForm do
      subject { described_class.from_params(attributes).with_context(current_organization: organization) }

      let(:organization) { create(:organization) }
      let(:attributes) do
        {
          name:,
          type:,
          service:,
          description:
        }
      end

      let(:name) { "awesome_cookie" }
      let(:type) { "cookie" }
      let(:service) { { "en" => "Awesome Service" } }
      let(:description) { { "en" => "Awesome cookie description" } }

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when name is missing" do
        let(:name) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when type is invalid" do
        let(:type) { "invalid_type" }

        it { is_expected.not_to be_valid }
      end

      context "when service is missing" do
        let(:service) { { "en" => "" } }

        it { is_expected.not_to be_valid }
      end

      context "when description is missing" do
        let(:description) { { "en" => "" } }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
