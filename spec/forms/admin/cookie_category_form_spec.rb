# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe CookieCategoryForm do
      subject { described_class.from_params(attributes).with_context(current_organization: organization) }

      let(:organization) { create(:organization) }
      let(:attributes) do
        {
          slug:,
          title:,
          description:,
          mandatory:,
          visibility:
        }
      end

      let(:slug) { "awesome-category" }
      let(:title) { { "en" => "Awesome Category" } }
      let(:description) { { "en" => "Awesome description" } }
      let(:mandatory) { false }
      let(:visibility) { "default" }

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when slug is missing" do
        let(:slug) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when slug has invalid format" do
        let(:slug) { "Invalid Slug!" }

        it { is_expected.not_to be_valid }
      end

      context "when slug has uppercase letters" do
        let(:slug) { "Invalid-Slug" }

        it { is_expected.not_to be_valid }
      end

      context "when title is missing" do
        let(:title) { { "en" => "" } }

        it { is_expected.not_to be_valid }
      end

      context "when description is missing" do
        let(:description) { { "en" => "" } }

        it { is_expected.not_to be_valid }
      end

      context "when visibility is valid" do
        CookieCategoryForm::VISIBILITY_STATES.each do |visibility_state|
          context "when visibility is #{visibility_state}" do
            let(:visibility) { visibility_state }

            it { is_expected.to be_valid }
          end
        end
      end
    end
  end
end
