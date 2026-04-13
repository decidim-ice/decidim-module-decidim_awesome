# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe CookieItemForm do
      subject { described_class.from_params(attributes).with_context(current_organization: organization, id:, category:) }

      let(:organization) { create(:organization) }
      let(:attributes) do
        {
          name:,
          type:,
          service:,
          description:,
          expiration:
        }
      end
      let(:category) { nil }
      let(:id) { nil }

      let(:name) { "awesome_cookie" }
      let(:type) { "cookie" }
      let(:expiration) { { "en" => "1 year" } }
      let(:service) { { "en" => "Awesome Service" } }
      let(:description) { { "en" => "Awesome cookie description" } }

      it { is_expected.to be_valid }

      it "returns the correct params" do
        expect(subject.to_params).to eq({
                                          "name" => name,
                                          "type" => type,
                                          "edited" => true,
                                          "service" => service,
                                          "description" => description,
                                          "expiration" => expiration
                                        })
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

      context "when editing an existing item" do
        let(:category) do
          {
            "default" => true,
            "items" => {
              "awesome_cookie" => {
                "name" => "awesome_cookie",
                "type" => "cookie",
                "expiration" => { "en" => "1 year" },
                "service" => { "en" => "Awesome Service" },
                "description" => { "en" => "Awesome cookie description" },
                "default" => default
              }
            }
          }
        end
        let(:default) { true }
        let(:id) { "awesome_cookie" }
        let(:description) { { "en" => "Updated description" } }
        let(:service) { { "en" => "Updated Service" } }

        it { is_expected.to be_valid }

        context "when trying to change non-editable fields" do
          let(:type) { "local_storage" }
          let(:expiration) { { "en" => "2 years" } }
          let(:name) { "new_cookie_name" }

          it { is_expected.not_to be_valid }

          context "when blocked is false" do
            let(:default) { false }

            it { is_expected.to be_valid }
          end
        end

        context "when name is not unique within the category" do
          let(:category) do
            {
              "items" => {
                "awesome_cookie" => {
                  "name" => "awesome_cookie",
                  "type" => "cookie",
                  "expiration" => { "en" => "1 year" },
                  "service" => { "en" => "Awesome Service" },
                  "description" => { "en" => "Awesome cookie description" }
                },
                "existing_cookie" => {
                  "name" => "existing_cookie",
                  "type" => "cookie",
                  "expiration" => { "en" => "1 year" },
                  "service" => { "en" => "Existing Service" },
                  "description" => { "en" => "Existing cookie description" }
                }
              }
            }
          end

          it { is_expected.to be_valid }

          context "when changing the name to an existing one" do
            let(:name) { "existing_cookie" }

            it { is_expected.not_to be_valid }
          end
        end
      end
    end
  end
end
