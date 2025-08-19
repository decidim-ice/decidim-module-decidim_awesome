# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe CreateAuthorizationGroup do
      subject { described_class.new(organization) }

      let(:organization) { create(:organization) }
      let(:context) do
        {
          current_user: create(:user, organization:),
          current_organization: organization
        }
      end
      let(:another_params) do
        {
          allow_images_in_editors: true,
          allow_videos_in_editors: true
        }
      end
      let(:another_form) do
        ConfigForm.from_params(another_params).with_context(context)
      end
      let(:another_config) { UpdateConfig.new(another_form) }
      let(:authorization_groups) do
        {
          "some-group" => {
            "authorization_handlers" => {
              "dummy_authorization_handler" => {}
            }
          }
        }
      end

      describe "when valid" do
        it "broadcasts :ok and creates a Hash" do
          expect { subject.call }.to broadcast(:ok)

          expect(AwesomeConfig.find_by(organization:, var: :authorization_groups).value).to be_a(Hash)
          expect(AwesomeConfig.find_by(organization:, var: :authorization_groups).value.keys.count).to eq(1)
        end

        context "and entries already exist" do
          let!(:config) { create(:awesome_config, organization:, var: :authorization_groups, value: authorization_groups) }

          shared_examples "has css boxes content" do
            it "do not removes previous entries" do
              expect { subject.call }.to broadcast(:ok)

              expect(AwesomeConfig.find_by(organization:, var: :authorization_groups).value.keys.count).to eq(2)
              expect(AwesomeConfig.find_by(organization:, var: :authorization_groups).value.values).to include(authorization_groups.values.first)
            end
          end

          it_behaves_like "has css boxes content"

          context "and another configuration is created" do
            before do
              another_config.call
            end

            it "modifies the other config" do
              expect(AwesomeConfig.find_by(organization:, var: :allow_images_in_editors).value).to be(true)
              expect(AwesomeConfig.find_by(organization:, var: :allow_videos_in_editors).value).to be(true)
            end

            it_behaves_like "has css boxes content"
          end

          context "and another configuration is updated" do
            let!(:existing_config) { create(:awesome_config, organization:, var: :allow_images_in_editors, value: false) }

            before do
              another_config.call
            end

            it "modifies the other config" do
              expect(AwesomeConfig.find_by(organization:, var: :allow_images_in_editors).value).to be(true)
              expect(AwesomeConfig.find_by(organization:, var: :allow_videos_in_editors).value).to be(true)
            end

            it_behaves_like "has css boxes content"
          end
        end
      end

      describe "when invalid" do
        subject { described_class.new("nonsense") }

        it "broadcasts :invalid and does not modify the config options" do
          expect { subject.call }.to broadcast(:invalid)

          expect(AwesomeConfig.find_by(organization:, var: :authorization_groups)).to be_nil
        end
      end
    end
  end
end
