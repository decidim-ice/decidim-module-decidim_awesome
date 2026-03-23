# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe CookieCategoryForm do
      subject { described_class.from_params(attributes).with_context(current_organization: organization, categories:, id:) }

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
      let(:categories) { {} }
      let(:id) { nil }

      let(:slug) { "awesome-category" }
      let(:title) { { "en" => "Awesome Category" } }
      let(:description) { { "en" => "Awesome description" } }
      let(:mandatory) { false }
      let(:visibility) { "visible" }

      it { is_expected.to be_valid }

      it "returns the correct params" do
        expect(subject.to_params).to eq({
                                          "slug" => slug,
                                          "title" => title,
                                          "description" => description,
                                          "mandatory" => mandatory,
                                          "visibility" => visibility,
                                          "edited" => true
                                        })
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

      context "when editing a blocked category" do
        let(:categories) do
          {
            "awesome-category" => {
              "slug" => "awesome-category",
              "blocked" => true
            }
          }
        end
        let(:id) { "awesome-category" }

        it { is_expected.not_to be_valid }

        context "when mandatory is set" do
          let(:mandatory) { true }

          it { is_expected.to be_valid }

          context "when visibility is set to hidden" do
            let(:visibility) { "hidden" }

            it { is_expected.to be_invalid }
          end
        end
      end

      context "when slug is not unique" do
        let(:categories) do
          {
            "awesome-category" => {
              "slug" => "awesome-category"
            },
            "existing-category" => {
              "slug" => "existing-category"
            }
          }
        end
        let(:id) { "awesome-category" }

        it { is_expected.to be_valid }

        context "when slug is changed" do
          let(:slug) { "different-slug" }

          it { is_expected.to be_valid }

          context "when slug is changed to an existing slug" do
            let(:slug) { "existing-category" }

            it { is_expected.not_to be_valid }
          end

          context "when existing category is slug-blocked" do
            let(:categories) do
              {
                "awesome-category" => {
                  "slug" => "awesome-category",
                  "default" => true
                }
              }
            end

            it { is_expected.not_to be_valid }
          end
        end
      end
    end
  end
end
