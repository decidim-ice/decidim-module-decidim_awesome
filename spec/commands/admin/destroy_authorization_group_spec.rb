# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe DestroyAuthorizationGroup do
      subject { described_class.new(key, organization) }

      let(:organization) { create(:organization) }
      let(:force_authorizations) do
        {
          "foo" => {
            "authorization_handlers" => {
              "dummy_authorization_handler" => {}
            }
          },
          "bar" => {
            "authorization_handlers" => {
              "dummy_authorization_handler" => { "options" => {} }
            }
          }
        }
      end
      let(:key) { "foo" }
      let!(:config) { create(:awesome_config, organization:, var: :force_authorizations, value: force_authorizations) }

      describe "when valid" do
        it "broadcasts :ok and removes the item" do
          expect { subject.call }.to broadcast(:ok)

          expect(AwesomeConfig.find_by(organization:, var: :force_authorizations).value).to be_a(Hash)
          expect(AwesomeConfig.find_by(organization:, var: :force_authorizations).value.keys.count).to eq(1)
          expect(AwesomeConfig.find_by(organization:, var: :force_authorizations).value.keys).to include("bar")
          expect(AwesomeConfig.find_by(organization:, var: :force_authorizations).value.keys).not_to include("foo")
          expect(AwesomeConfig.find_by(organization:, var: :force_authorizations).value.values).to include(force_authorizations["bar"])
          expect(AwesomeConfig.find_by(organization:, var: :force_authorizations).value.values).not_to include(force_authorizations["foo"])
        end
      end

      describe "when invalid" do
        let(:key) { "nonsense" }

        it "broadcasts :invalid and does not modify the config options" do
          expect { subject.call }.to broadcast(:invalid)

          expect(AwesomeConfig.find_by(organization:, var: :force_authorizations).value).to be_a(Hash)
          expect(AwesomeConfig.find_by(organization:, var: :force_authorizations).value.keys.count).to eq(2)
        end
      end

      describe "when has a constraint" do
        let(:config_helper) { create(:awesome_config, organization:, var: :proposal_custom_field_foo) }
        let!(:constraint) { create(:config_constraint, awesome_config: config_helper, settings: { "test" => 1 }) }

        it "removes the config helper and the constraint" do
          expect(AwesomeConfig.find_by(organization:, var: :proposal_custom_field_foo).constraints.count).to eq(1)
          expect { subject.call }.to broadcast(:ok)

          expect(AwesomeConfig.find_by(organization:, var: :force_authorizations).value.keys).not_to include("foo")
          expect(AwesomeConfig.find_by(organization:, var: :force_authorization_foo)).to be_nil
        end
      end
    end
  end
end
