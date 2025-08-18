# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe ConfigForm do
      subject { described_class.from_params(attributes).with_context(context) }

      let(:context) do
        {
          current_organization: organization
        }
      end
      let(:organization) { create(:organization, available_authorizations: [:dummy_authorization_handler, :another_dummy_authorization_handler]) }
      let(:attributes) do
        {
          allow_images_in_editors: true,
          allow_videos_in_editors: true
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
      let(:private_custom_fields) do
        {
          foo: valid_fields
        }
      end
      let(:user_timezone) { true }
      let(:force_authorization_with_any_method) { true }
      let(:force_authorization_help_text) do
        { en: "Help text" }
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
      let(:hashcash_signup) { true }
      let(:hashcash_signup_bits) { 21 }
      let(:hashcash_login) { true }
      let(:hashcash_login_bits) { 18 }

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      describe "valid_keys" do
        let(:attributes) do
          {
            force_authorization_help_text_en: "Help text"
          }
        end

        it "extracts valid keys from params" do
          expect(subject.valid_keys).to eq([:force_authorization_help_text])
        end
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

          it { is_expected.not_to be_valid }
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

          it { is_expected.not_to be_valid }
        end

        context "and sending labels with html" do
          let(:valid_fields) { '[{"label":"<p>Santana</p>"}]' }

          it "sanitize labels from html" do
            expect(subject.proposal_custom_fields[:foo]).to include("Santana")
            expect(subject.proposal_custom_fields[:foo]).not_to include("<p>Santana</p>")
          end
        end
      end

      describe "proposal private custom fields" do
        let(:attributes) do
          {
            proposal_custom_fields: custom_fields,
            proposal_private_custom_fields: private_custom_fields
          }
        end

        it { is_expected.to be_valid }

        context "and invalid JSON" do
          let(:private_custom_fields) do
            {
              foo: invalid_fields
            }
          end

          it { is_expected.not_to be_valid }
        end
      end

      describe "user timezone" do
        let(:attributes) do
          {
            user_timezone:
          }
        end

        it { is_expected.to be_valid }

        context "and user timezone is false" do
          let(:user_timezone) { false }

          it { is_expected.to be_valid }
        end
      end

      describe "validators" do
        let(:attributes) do
          {
            validate_title_min_length:,
            validate_title_max_caps_percent:,
            validate_title_max_marks_together:,
            validate_title_start_with_caps:,
            validate_body_min_length:,
            validate_body_max_caps_percent:,
            validate_body_max_marks_together:,
            validate_body_start_with_caps:,
            hashcash_signup:,
            hashcash_signup_bits:,
            hashcash_login:,
            hashcash_login_bits:
          }
        end

        it { is_expected.to be_valid }

        context "and title start with caps is false" do
          let(:validate_title_start_with_caps) { false }

          it { is_expected.to be_valid }
        end

        context "and title min length is empty" do
          let(:validate_title_min_length) { nil }

          it { is_expected.not_to be_valid }
        end

        context "and title min length is zero" do
          let(:validate_title_min_length) { 0 }

          it { is_expected.not_to be_valid }
        end

        context "and title min length greater than 100" do
          let(:validate_title_min_length) { 101 }

          it { is_expected.not_to be_valid }
        end

        context "and body min length is empty" do
          let(:validate_body_min_length) { nil }

          it { is_expected.not_to be_valid }
        end

        context "and body min length is zero" do
          let(:validate_body_min_length) { 0 }

          it { is_expected.to be_valid }
        end

        context "and title max caps percent empty" do
          let(:validate_title_max_caps_percent) { nil }

          it { is_expected.not_to be_valid }
        end

        context "and title max caps percent is zero" do
          let(:validate_title_max_caps_percent) { 0 }

          it { is_expected.to be_valid }
        end

        context "and title max caps percent is bigger than 100" do
          let(:validate_title_max_caps_percent) { 101 }

          it { is_expected.not_to be_valid }
        end

        context "and body start with caps is false" do
          let(:validate_body_start_with_caps) { false }

          it { is_expected.to be_valid }
        end

        context "and body max caps percent empty" do
          let(:validate_body_max_caps_percent) { nil }

          it { is_expected.not_to be_valid }
        end

        context "and body max caps percent is zero" do
          let(:validate_body_max_caps_percent) { 0 }

          it { is_expected.to be_valid }
        end

        context "and body max caps percent is bigger than 100" do
          let(:validate_body_max_caps_percent) { 101 }

          it { is_expected.not_to be_valid }
        end

        context "and title max marks together is empty" do
          let(:validate_title_max_marks_together) { nil }

          it { is_expected.not_to be_valid }
        end

        context "and title max marks together is zero" do
          let(:validate_title_max_marks_together) { 0 }

          it { is_expected.not_to be_valid }
        end

        context "and body max marks together is empty" do
          let(:validate_body_max_marks_together) { nil }

          it { is_expected.not_to be_valid }
        end

        context "and body max marks together is zero" do
          let(:validate_body_max_marks_together) { 0 }

          it { is_expected.not_to be_valid }
        end

        context "and hashcash signup bits is empty" do
          let(:hashcash_signup_bits) { nil }

          it { is_expected.not_to be_valid }
        end

        context "and hashcash signup bits is less than 10" do
          let(:hashcash_signup_bits) { 9 }

          it { is_expected.not_to be_valid }
        end

        context "and hashcash signup bits is greater than 50" do
          let(:hashcash_signup_bits) { 51 }

          it { is_expected.not_to be_valid }
        end

        context "and hashcash login bits is empty" do
          let(:hashcash_login_bits) { nil }

          it { is_expected.not_to be_valid }
        end

        context "and hashcash login bits is less than 10" do
          let(:hashcash_login_bits) { 9 }

          it { is_expected.not_to be_valid }
        end

        context "and hashcash login bits is greater than 50" do
          let(:hashcash_login_bits) { 51 }

          it { is_expected.not_to be_valid }
        end
      end
    end
  end
end
