# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe DestroyScopedStyle do
      subject { described_class.new(key, organization) }

      let(:organization) { create(:organization) }
      let(:styles) do
        {
          foo: ".body {background: red;}",
          bar: ".body {background: blue;}"
        }
      end
      let(:key) { "foo" }
      let!(:config) { create(:awesome_config, organization:, var: :scoped_styles, value: styles) }

      describe "when valid" do
        it "broadcasts :ok and removes the item" do
          expect { subject.call }.to broadcast(:ok)

          expect(AwesomeConfig.find_by(organization:, var: :scoped_styles).value).to be_a(Hash)
          expect(AwesomeConfig.find_by(organization:, var: :scoped_styles).value.keys.count).to eq(1)
          expect(AwesomeConfig.find_by(organization:, var: :scoped_styles).value.keys).to include("bar")
          expect(AwesomeConfig.find_by(organization:, var: :scoped_styles).value.keys).not_to include("foo")
          expect(AwesomeConfig.find_by(organization:, var: :scoped_styles).value.values).to include(".body {background: blue;}")
          expect(AwesomeConfig.find_by(organization:, var: :scoped_styles).value.values).not_to include(".body {background: red;}")
        end
      end

      describe "when invalid" do
        let(:key) { "nonsense" }

        it "broadcasts :invalid and does not modifiy the config options" do
          expect { subject.call }.to broadcast(:invalid)

          expect(AwesomeConfig.find_by(organization:, var: :scoped_styles).value).to be_a(Hash)
          expect(AwesomeConfig.find_by(organization:, var: :scoped_styles).value.keys.count).to eq(2)
        end
      end

      describe "when has a constraint" do
        let(:config_helper) { create(:awesome_config, organization:, var: :scoped_style_foo) }
        let!(:constraint) { create(:config_constraint, awesome_config: config_helper, settings: { "test" => 1 }) }

        it "removes the config helper and the constraint" do
          expect(AwesomeConfig.find_by(organization:, var: :scoped_style_foo).constraints.count).to eq(1)
          expect { subject.call }.to broadcast(:ok)

          expect(AwesomeConfig.find_by(organization:, var: :scoped_styles).value.keys).not_to include("foo")
          expect(AwesomeConfig.find_by(organization:, var: :scoped_styles_foo)).to be_nil
        end
      end
    end
  end
end
