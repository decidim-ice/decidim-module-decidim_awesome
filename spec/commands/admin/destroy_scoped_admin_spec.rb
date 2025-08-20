# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe DestroyScopedAdmin do
      subject { described_class.new(key, organization) }

      let(:organization) { create(:organization) }
      let(:admins) do
        {
          foo: [123, 456],
          bar: [789, 901]
        }
      end
      let(:key) { "foo" }
      let!(:config) { create(:awesome_config, organization:, var: :scoped_admins, value: admins) }

      describe "when valid" do
        it "broadcasts :ok and removes the item" do
          expect { subject.call }.to broadcast(:ok)

          expect(AwesomeConfig.find_by(organization:, var: :scoped_admins).value).to be_a(Hash)
          expect(AwesomeConfig.find_by(organization:, var: :scoped_admins).value.keys.count).to eq(1)
          expect(AwesomeConfig.find_by(organization:, var: :scoped_admins).value.keys).to include("bar")
          expect(AwesomeConfig.find_by(organization:, var: :scoped_admins).value.keys).not_to include("foo")
          expect(AwesomeConfig.find_by(organization:, var: :scoped_admins).value.values).to include([789, 901])
          expect(AwesomeConfig.find_by(organization:, var: :scoped_admins).value.values).not_to include([123, 456])
        end
      end

      describe "when invalid" do
        let(:key) { "nonsense" }

        it "broadcasts :invalid and does not modify the config options" do
          expect { subject.call }.to broadcast(:invalid)

          expect(AwesomeConfig.find_by(organization:, var: :scoped_admins).value).to be_a(Hash)
          expect(AwesomeConfig.find_by(organization:, var: :scoped_admins).value.keys.count).to eq(2)
        end
      end

      describe "when has a constraint" do
        let(:config_helper) { create(:awesome_config, organization:, var: :scoped_admin_foo) }
        let!(:constraint) { create(:config_constraint, awesome_config: config_helper, settings: { "test" => 1 }) }

        it "removes the config helper and the constraint" do
          expect(AwesomeConfig.find_by(organization:, var: :scoped_admin_foo).constraints.count).to eq(1)
          expect { subject.call }.to broadcast(:ok)

          expect(AwesomeConfig.find_by(organization:, var: :scoped_admins).value.keys).not_to include("foo")
          expect(AwesomeConfig.find_by(organization:, var: :scoped_admin_foo)).to be_nil
        end
      end
    end
  end
end
