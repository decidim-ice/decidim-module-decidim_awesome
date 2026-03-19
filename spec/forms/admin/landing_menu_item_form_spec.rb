# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe LandingMenuItemForm do
      subject { described_class.from_params(attributes).with_context(current_organization: organization) }

      let(:organization) { create(:organization) }
      let(:attributes) { { url:, name_en: "Home" } }
      let(:url) { "#about" }

      context "with anchor URL" do
        let(:url) { "#about-section" }

        it { is_expected.to be_valid }
      end

      context "with internal path URL" do
        let(:url) { "/processes/my-process" }

        it { is_expected.to be_valid }
      end

      context "with https URL" do
        let(:url) { "https://example.com/page" }

        it { is_expected.to be_valid }
      end

      context "with blank URL" do
        let(:url) { "" }

        it { is_expected.to be_valid }
      end

      context "with javascript URL" do
        let(:url) { "javascript:alert(1)" }

        it { is_expected.not_to be_valid }
      end

      context "with http URL" do
        let(:url) { "http://example.com" }

        it { is_expected.not_to be_valid }
      end

      context "with data URL" do
        let(:url) { "data:text/html,<script>alert(1)</script>" }

        it { is_expected.not_to be_valid }
      end

      context "with protocol-relative URL" do
        let(:url) { "//evil.com" }

        it { is_expected.not_to be_valid }
      end

      it "defaults visible to true" do
        expect(subject.visible).to be(true)
      end
    end
  end
end
