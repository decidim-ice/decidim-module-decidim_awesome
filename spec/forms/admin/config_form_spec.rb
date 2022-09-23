# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe ConfigForm do
      subject { described_class.from_params(attributes) }

      let(:attributes) do
        {
          allow_images_in_full_editor: true,
          allow_images_in_small_editor: true
        }
      end

      let(:custom_styles) do
        {
          foo: valid_css
        }
      end
      let(:valid_css) { ".valid_css {background: red;}" }
      let(:invalid_css) { "invalid_css {background: ;}" }
      let(:custom_fields) do
        {
          foo: valid_fields
        }
      end
      let(:valid_fields) { '[{"foo":"bar"}]' }
      let(:invalid_fields) { '[{"foo":"bar"}]{"baz":"zet"}' }

      let(:validate_title_min_length) { 15 }
      let(:validate_title_max_caps_percent) { 25 }
      let(:validate_title_max_marks_together) { 2 }
      let(:validate_title_start_with_caps) { true }
      let(:validate_body_min_length) { 15 }
      let(:validate_body_max_caps_percent) { 25 }
      let(:validate_body_max_marks_together) { 2 }
      let(:validate_body_start_with_caps) { true }

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      describe "custom styles" do
        let(:attributes) do
          {
            scoped_styles: custom_styles
          }
        end

        it { is_expected.to be_valid }

        context "and invalid CSS" do
          let(:custom_styles) do
            {
              foo: invalid_css
            }
          end

          it { is_expected.to be_invalid }
        end
      end

      describe "proposal custom fields" do
        let(:attributes) do
          {
            proposal_custom_fields: custom_fields
          }
        end

        it { is_expected.to be_valid }

        context "and invalid JSON" do
          let(:custom_fields) do
            {
              foo: invalid_fields
            }
          end

          it { is_expected.to be_invalid }
        end

        context "and sending labels with html" do
          let(:valid_fields) { '[{"label":"<p>Santana</p>"}]' }

          it "sanitize labels from html" do
            expect(subject.proposal_custom_fields[:foo]).to include("Santana")
            expect(subject.proposal_custom_fields[:foo]).not_to include("<p>Santana</p>")
          end
        end
      end

      describe "validators" do
        let(:attributes) do
          {
            validate_title_min_length: validate_title_min_length,
            validate_title_max_caps_percent: validate_title_max_caps_percent,
            validate_title_max_marks_together: validate_title_max_marks_together,
            validate_title_start_with_caps: validate_title_start_with_caps,
            validate_body_min_length: validate_body_min_length,
            validate_body_max_caps_percent: validate_body_max_caps_percent,
            validate_body_max_marks_together: validate_body_max_marks_together,
            validate_body_start_with_caps: validate_body_start_with_caps
          }
        end

        it { is_expected.to be_valid }

        context "and title start with caps is empty" do
          let(:validate_title_start_with_caps) { nil }

          it { is_expected.to be_invalid }
        end

        context "and title min length is empty" do
          let(:validate_title_min_length) { nil }

          it { is_expected.to be_invalid }
        end

        context "and title min length is zero" do
          let(:validate_title_min_length) { 0 }

          it { is_expected.to be_invalid }
        end

        context "and title min length greater than 100" do
          let(:validate_title_min_length) { 101 }

          it { is_expected.to be_invalid }
        end

        context "and body min length is empty" do
          let(:validate_body_min_length) { nil }

          it { is_expected.to be_invalid }
        end

        context "and body min length is zero" do
          let(:validate_body_min_length) { 0 }

          it { is_expected.to be_valid }
        end

        context "and title max caps percent empty" do
          let(:validate_title_max_caps_percent) { nil }

          it { is_expected.to be_invalid }
        end

        context "and title max caps percent is zero" do
          let(:validate_title_max_caps_percent) { 0 }

          it { is_expected.to be_valid }
        end

        context "and title max caps percent is bigger than 100" do
          let(:validate_title_max_caps_percent) { 101 }

          it { is_expected.to be_invalid }
        end

        context "and body start with caps is empty" do
          let(:validate_body_start_with_caps) { nil }

          it { is_expected.to be_invalid }
        end

        context "and body max caps percent empty" do
          let(:validate_body_max_caps_percent) { nil }

          it { is_expected.to be_invalid }
        end

        context "and body max caps percent is zero" do
          let(:validate_body_max_caps_percent) { 0 }

          it { is_expected.to be_valid }
        end

        context "and body max caps percent is bigger than 100" do
          let(:validate_body_max_caps_percent) { 101 }

          it { is_expected.to be_invalid }
        end

        context "and title max marks together is empty" do
          let(:validate_title_max_marks_together) { nil }

          it { is_expected.to be_invalid }
        end

        context "and title max marks together is zero" do
          let(:validate_title_max_marks_together) { 0 }

          it { is_expected.to be_invalid }
        end

        context "and body max marks together is empty" do
          let(:validate_body_max_marks_together) { nil }

          it { is_expected.to be_invalid }
        end

        context "and body max marks together is zero" do
          let(:validate_body_max_marks_together) { 0 }

          it { is_expected.to be_invalid }
        end
      end
    end
  end
end
