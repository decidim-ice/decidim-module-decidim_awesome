# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe MenuForm do
      subject { described_class.from_params(attributes).with_context(current_organization: organization) }

      let(:organization) { create :organization }
      let(:attributes) do
        {
          raw_label: label,
          url: url,
          position: position,
          target: target,
          visibility: visibility
        }
      end

      let(:label) do
        {
          "en" => "Menu english",
          "ca" => "Menu catalan"
        }
      end
      let(:url) { "/some-path" }
      let(:position) { 2 }
      let(:target) { "_blank" }
      let(:visibility) { "hidden" }

      context "when everything is OK" do
        it { is_expected.to be_valid }

        it "returns normalized values" do
          expect(subject.to_params).to eq(label: label, url: url, position: position, target: target, visibility: visibility)
        end
      end

      context "when label is not a hash" do
        let(:label) { nil }

        it { is_expected.to be_invalid }
      end

      context "when url is empty" do
        let(:url) { "" }

        it { is_expected.to be_invalid }
      end

      context "when position is not numeric" do
        let(:position) { "hacker!" }

        it { is_expected.to be_invalid }
      end

      context "when target is not included in options" do
        let(:target) { "hacker!" }

        it { is_expected.to be_invalid }
      end

      context "when visibility is not included in options" do
        let(:visibility) { "hacker!" }

        it { is_expected.to be_invalid }
      end
    end
  end
end
